# frozen_string_literal: true
#
# Class attribute updates + monkey-patching customizations for Hyrax.
Rails.application.reloader.to_prepare do
  # Bump start the Noid minter in development:
  # Using Bulkrax on a brand-new Hyrax application will wreak havoc with
  # multiple async jobs running MinterState.create! with the same "unique"
  # parameters, done as part of the database-backed minting process.
  # Initializing the minter class via private method :instance
  # will create the state if it's missing. Note: this needs to be wrapped
  # in a begin/rescue block because Noid::Rails::Minter::File doesn't have
  # an :instance method and will yell about it.
  #
  # @see https://github.com/samvera/noid-rails/blob/v3.1.0/lib/noid/rails/minter/db.rb#L67-L78
  begin
    Hyrax.config.noid_minter_class.new.send(:instance) if Rails.env.development?
  rescue # rubocop:disable Lint/SuppressedException
  end

  Hyrax::Dashboard::CollectionsController.presenter_class = Spot::CollectionPresenter
  Hyrax::Dashboard::CollectionsController.form_class = Spot::Forms::CollectionForm
  Hyrax::Dashboard::CollectionsController.include Spot::CollectionsControllerBehavior

  Hyrax::CollectionsController.presenter_class = Spot::CollectionPresenter
  Hyrax::CollectionsController.include Spot::CollectionsControllerBehavior

  Hyrax::CurationConcern.actor_factory.swap(Hyrax::Actors::CollectionsMembershipActor, Spot::Actors::CollectionsMembershipActor)

  # Use our own FileSetDerivativesService first and fall back to the Hyrax services
  # for formats we don't currently handle uniquely.
  Hyrax::DerivativeService.services = [
    ::Spot::FileSetDerivativesService,
    ::Hyrax::FileSetDerivativesService
  ]

  # Change the layout used for pages and the contact form
  Hyrax::ContactFormController.class_eval { layout 'hyrax/1_column' }
  Hyrax::PagesController.class_eval { layout 'hyrax/1_column' }

  # the dashboard/my/collections (+ thus, dashboard/collections) controller defines
  # blacklight facets + uses I18n.t to provide a label. as we've found from past experience,
  # this can get called _before_ all of the locales are loaded, resulting in a
  # "translation missing" message being provided as a fall-back label. this should
  # prevent that error from appearing by replacing the +translate+ calls with a symbolized
  # I18n key (see also 0717dee, + catalog_controller.rb)
  [Hyrax::My::CollectionsController, Hyrax::Dashboard::CollectionsController].each do |klass|
    klass.class_eval do
      def self.update_facet_labels!
        blacklight_config.facet_fields['visibility_ssi'].label = :'hyrax.dashboard.my.heading.visibility'
        blacklight_config.facet_fields[Hyrax.config.collection_type_index_field].label = :'hyrax.dashboard.my.heading.collection_type'
        blacklight_config.facet_fields['has_model_ssim'].label = :'hyrax.dashboard.my.heading.collection_type'
      end
      update_facet_labels!
    end
  end

  # same as previous: updating facet labels for dashboard works controller
  [Hyrax::My::WorksController, Hyrax::Dashboard::WorksController].each do |klass|
    klass.class_eval do
      def self.update_facet_labels!
        blacklight_config.facet_fields['visibility_ssi'].label = :'hyrax.dashboard.my.heading.visibility'
      end
      update_facet_labels!
    end
  end

  # We're using an older version of the FITSServlet tool (1.1.3 as of 2019-12-03,
  # anything higher throws an exception that I can't nail down) that predates
  # a change to set the response encoding to UTF-8. So we need to do this as
  # early as possible within the Characterization tool.
  require 'hydra-file_characterization'

  Hydra::FileCharacterization::Characterizers::FitsServlet.class_eval do
    # Wrap the datafile= param in quotes to handle filenames with spaces
    def command
      %(curl -k -F datafile=@"#{filename}" #{ENV['FITS_SERVLET_URL']}/examine)
    end

    def output
      super.encode('UTF-8', invalid: :replace)
    end
  end

  # Add our SolrSuggestActor to the front of the default actor-stack. This will
  # trigger a build of all of the Solr suggestion dictionaries at the end of
  # each create, update, destroy process (each method calls the next actor and _then_
  # enqueues the job).
  Hyrax::CurationConcern.actor_factory.unshift(SolrSuggestActor)

  # By default, +Hydra::AccessControls::Embargo#active?+ compares the
  # embargo_release_date (a DateTime) to +Date.today+ (a Date). When
  # the release date is the same day as today, we'll get a truthy return value
  # when it should be falsey.
  #
  #   Date.today < DateTime.parse(Date.today.to_s)
  #   # => true
  #
  #   DateTime.parse(Date.today.to_s) < DateTime.parse(Date.today.to_s)
  #   # => false
  #
  # @see https://github.com/samvera/hydra-head/blob/v10.7.0/hydra-access-controls/app/models/hydra/access_controls/embargo.rb#L13-L15
  Hydra::AccessControls::Embargo.class_eval do
    def active?
      embargo_release_date.present? && DateTime.current < embargo_release_date
    end
  end

  Hydra::AccessControls::Lease.class_eval do
    def active?
      lease_expiration_date.present? && DateTime.current < lease_expiration_date
    end
  end

  # Updating how SimpleForm generates labels so that we can use the same locales
  # for the form as those for the metadata display.
  SimpleForm::Inputs::Base.class_eval do
    protected def raw_label_text
      options[:label] || I18n.t("blacklight.search.fields.#{attribute_name}", default: label_translation)
    end
  end

  # Adding label support for metadata-only records
  Hyrax::PermissionBadge.class_eval do
    old_visibility_label_class = Hyrax::PermissionBadge::VISIBILITY_LABEL_CLASS.dup
    remove_const(:VISIBILITY_LABEL_CLASS) if const_defined?(:VISIBILITY_LABEL_CLASS)
    const_set(:VISIBILITY_LABEL_CLASS, old_visibility_label_class.tap { |h| h[:metadata] = 'label-info' }.freeze)
  end

  # Define this constant, intended to be similar to AdminSet::DEFAULT_ID
  AdminSet::STUDENT_WORK_ID = Spot::StudentWorkAdminSetCreateService::ADMIN_SET_ID

  # Our own Characterization Service subclass that uses :fits_servlet by default
  CharacterizeJob.characterization_service = Spot::CharacterizationService

  # Override the Browse-Everything Retreiver to take S3 URIs
  BrowseEverything::Retriever.prepend(Spot::RetrievesS3Urls)
  BrowseEverything::Retriever.class_eval do
    class << self
      prepend Spot::RetrievesS3Urls::ClassMethods
    end
  end

  # To be honest, I'm not sure why the Hyrax code doesn't work as-is,
  # but rewriting the solr_params[:sort] assignment to this kinda
  # wonky one-liner seems to preserve user-selected sorting. ¯\_(ツ)_/¯
  #
  # @see https://github.com/samvera/hyrax/blob/main/app/search_builders/hyrax/collection_search_builder.rb#L36-L42
  Hyrax::CollectionMemberSearchBuilder.class_eval do
    def add_sorting_to_solr(solr_parameters)
      return if solr_parameters[:q]
      solr_parameters[:sort] ||= (sort || "title_sort_si asc")
    end
  end

  # Override to fix Hyrax bug where calling Hyrax::AdminSetCreateService.find_or_create_default_admin_set
  # will try to load an AdminSet's entire set of members when called.
  #
  # @see https://github.com/samvera/hyrax/issues/6171
  # @see https://github.com/WGBH-MLA/ams/commit/8983c933d7ffaf587ef9dbded74845eaae41ebea
  module Spot
    module AdminSetCreateServiceDecorator
      private

      def find_default_admin_set
        AdminSet.first
      end
    end
  end

  Hyrax::AdminSetCreateService.singleton_class.send(:prepend, Spot::AdminSetCreateServiceDecorator) unless Rails.env.test?

  # Only store entitlements related to us in the session to prevent a cookie overflow.
  #
  # @see https://github.com/biola/rack-cas/blob/v0.16.1/lib/rack/cas.rb#L96-L102
  # rubocop:disable Style/IfUnlessModifier
  require 'rack/cas'
  Rack::CAS.class_eval do
    def store_session(request, user, ticket, extra_attrs = {})
      if RackCAS.config.extra_attributes_filter?
        extra_attrs.select! { |key, _val| RackCAS.config.extra_attributes_filter.map(&:to_s).include?(key.to_s) }
      end

      if extra_attrs['eduPersonEntitlement'].present?
        extra_attrs['eduPersonEntitlement'] = Array.wrap(extra_attrs['eduPersonEntitlement']).select do |val|
          URI.parse(val).host == Spot::CasUserRolesService.entitlement_host
        end
      end

      request.session['cas'] = { 'user' => user, 'ticket' => ticket, 'extra_attributes' => extra_attrs }
    end
  end

  # Modifying how Questiong Authority returns AssignFAST results by
  # converting fst ids into URLs
  require 'qa/authorities/assign_fast'
  Qa::Authorities::AssignFast::GenericAuthority.class_eval do
    private

    def parse_authority_response(raw_response)
      raw_response['response']['docs'].map do |doc|
        index = Qa::Authorities::AssignFast.index_for_authority(subauthority)
        term = doc[index].first
        term += " (USE #{doc['auth']})" if doc['type'] == 'alt'
        fast_id = Array.wrap(doc['idroot']).first

        {
          fast_id: fast_id,
          id: "http://id.worldcat.org/fast/#{fast_id.gsub(/^fst/, '')}",
          label: term,
          type: doc['type'],
          value: doc['auth']
        }
      end
    end
  end

  # In order for us to search assignFAST by FAST IDs, we need to
  # add the 'idroot' searchIndex as a valid subauthority for AssignFast
  Qa::Authorities::AssignFastSubauthority.module_eval do
    def index_for_authority(authority)
      return authority if authority == 'idroot'

      Qa::Authorities::AssignFastSubauthority::SUBAUTHORITIES[authority]
    end

    def subauthorities
      Qa::Authorities::AssignFastSubauthority::SUBAUTHORITIES.keys + ['idroot']
    end
  end

  # Modifying the Video Runner for Hydra to use a customized Processor
  # which backports changes from 3.8.0
  #
  # @see https://github.com/samvera/hydra-derivatives/blob/v3.8.0/lib/hydra/derivatives/runners/video_derivatives.rb
  Hydra::Derivatives::VideoDerivatives.class_eval do
    def self.processor_class
      Spot::VideoProcessor
    end
  end

  # Add original file names and the transcript flag to presenter for file sets
  #
  # @see https://github.com/samvera/hyrax/blob/e4f8a06aaf1c9ec378f87764da59f73a8adf06d7/app/presenters/hyrax/file_set_presenter.rb
  Hyrax::FileSetPresenter.class_eval do
    delegate :original_filenames, :transcript_name,
             :stored_derivatives, to: :solr_document
  end

  # Add support for downloading file_set transcripts
  Hyrax::DownloadsController.prepend(Spot::DownloadsControllerBehavior)

  # Modifying Bulkrax ImporterJob so that it correctly fetches file sizes
  #
  # @see https://github.com/samvera/bulkrax/blob/v5.5.1/app/parsers/bulkrax/csv_parser.rb#L258
  #
  Bulkrax::ImporterJob.class_eval do
    # checks the file sizes of the download files to match the original files
    def all_files_completed?(importer)
      cloud_files = importer.parser_fields['cloud_file_paths']
      original_files = importer.parser_fields['original_file_paths']
      return true unless cloud_files.present? && original_files.present?

      imported_file_sizes = cloud_files.map { |_, v| get_file_size_from_s3(v['url']) }
      original_file_sizes = original_files.map { |imported_file| File.size(imported_file) }

      original_file_sizes == imported_file_sizes
    end

    # s3 file size fetch
    # @todo should we add handling for other types of cloud files?
    def get_file_size_from_s3(url)
      uri_parsed = ::Addressable::URI.parse(url)
      return unless uri_parsed.scheme == 's3'

      client = Aws::S3::Client.new
      resp = client.head_object(bucket: uri_parsed.host, key: uri_parsed.path[1..-1])
      resp.content_length
    end
  end

  # Bulkrax's parser replaces any whitespace character with a space, which kills paragraph breaks
  # and newlines. Our patch modifies the base #result method to only replace tabs with
  # spaces and strip lead/trailing spaces.
  #
  # @see app/services/concerns/spot/bulkrax_matcher_whitespace_patch.rb
  # @see spec/matchers/bulkrax/application_matcher_spec.rb
  Bulkrax::ApplicationMatcher.prepend(Spot::BulkraxMatcherWhitespacePatch)

  # Modifying the Downloads Controller to not send an unauthorized status for requests.
  # The unauthorized status breaks the laf only thumbnail.
  #
  # @see https://github.com/samvera/hyrax/blob/hyrax-v3.6.0/app/controllers/hyrax/downloads_controller.rb#L52-L63
  Hyrax::DownloadsController.class_eval do
    # Customize the :read ability in your Ability class, or override this method.
    # Hydra::Ability#download_permissions can't be used in this case because it assumes
    # that files are in a LDP basic container, and thus, included in the asset's uri.
    def authorize_download!
      authorize! :download, params[asset_param_key]
      # Deny access if the work containing this file is restricted by a workflow
      return unless workflow_restriction?(file_set_parent(params[asset_param_key]), ability: current_ability)
      raise Hyrax::WorkflowAuthorizationException
    rescue CanCan::AccessDenied, Hyrax::WorkflowAuthorizationException
      unauthorized_image = Rails.root.join("app", "assets", "images", "unauthorized.png")
      send_file unauthorized_image
    end
  end

  # Encountering an issue where Hyrax::PersistDirectlyContainedOutputFileService.retrieve_file_set requires
  # Hyrax::UploadedFile#file_set_uri to be an URI but querying for that URI throws an error (ActiveFedora
  # is appending the base root to the full uri, resulting in errors like:
  #     Ldp::BadRequest: Path contains empty element! /dev/ht/tp/:/http://fedora:8080/rest/dev/2v/23/vt/36/2v23vt362")
  Hyrax::UploadedFile.class_eval do
    def add_file_set!(file_set)
      uri = case file_set
            when ActiveFedora::Base
              file_set.uri
            when Hyrax::Resource
              file_set.id.is_a?(URI::HTTP) ? file_set.id : Hyrax::Base.id_to_uri(file_set.id.to_s)
            end

      update!(file_set_uri: uri) if uri.present?
    end
  end
end
