# frozen_string_literal: true
#
# Class attribute updates + monkey-patching customizations for Hyrax.
Rails.application.config.to_prepare do
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

  # Adding support for cloud files in importers
  Bulkrax::ImportersController.class_eval do
    private

    def files_for_import(file, cloud_files)
      return if file.blank? && cloud_files.blank?
      @importer[:parser_fields]['import_file_path'] = @importer.parser.write_import_file(file)
      if cloud_files.present?
        # For BagIt, there will only be one bag, so we get the file_path back and set import_file_path
        # For CSV, we expect only file uploads, so we won't get the file_path back
        # and we expect the import_file_path to be set already
        target = @importer.parser.retrieve_cloud_files(cloud_files)
        @importer[:parser_fields]['import_file_path'] = target if target.present?
      end
      @importer.save
    end
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

  Hyrax::AdminSetCreateService.singleton_class.send(:prepend, Spot::AdminSetCreateServiceDecorator)

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

  # Modifying Bulkrax DownloadCloudFiles job to be perform_later
  # so as not to overwhelm the system with large ingests
  #
  # @see https://github.com/samvera/bulkrax/blob/v5.5.1/app/parsers/bulkrax/csv_parser.rb#L258
  Bulkrax::CsvParser.class_eval do
    def retrieve_cloud_files(files)
      files_path = File.join(path_for_import, 'files')
      FileUtils.mkdir_p(files_path) unless File.exist?(files_path)
      files.each_pair do |_key, file|
        # fixes bug where auth headers do not get attached properly
        if file['auth_header'].present?
          file['headers'] ||= {}
          file['headers'].merge!(file['auth_header'])
        end
        # this only works for uniquely named files
        target_file = File.join(files_path, file['file_name'].tr(' ', '_'))
        # Now because we want the files in place before the importer runs
        # Problematic for a large upload
        Bulkrax::DownloadCloudFileJob.perform_later(file, target_file)
      end
      nil
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

      super
    end

    def subauthorities
      super + ['idroot']
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

  # Add original file names to presenter for file sets
  #
  # @see https://github.com/samvera/hyrax/blob/e4f8a06aaf1c9ec378f87764da59f73a8adf06d7/app/presenters/hyrax/file_set_presenter.rb
  Hyrax::FileSetPresenter.class_eval do
    delegate :original_filenames, to: :solr_document
  end
end
