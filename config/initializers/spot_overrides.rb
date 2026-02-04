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
      blacklight_config.facet_fields['visibility_ssi'].label = :'hyrax.dashboard.my.heading.visibility'
      blacklight_config.facet_fields[Hyrax.config.collection_type_index_field].label = :'hyrax.dashboard.my.heading.collection_type'
      blacklight_config.facet_fields['has_model_ssim'].label = :'hyrax.dashboard.my.heading.collection_type'
    end
  end

  # same as previous: updating facet labels for dashboard works controller
  [Hyrax::My::WorksController, Hyrax::Dashboard::WorksController].each do |klass|
    klass.class_eval do
      blacklight_config.facet_fields['visibility_ssi'].label = :'hyrax.dashboard.my.heading.visibility'
    end
  end

  # Rewrite Hyrax::DashboardController local mods to be a decorator.
  # @see app/controllers/concerns/spot/hyrax_dashboard_controller_decorator.rb
  Hyrax::DashboardController.prepend(Spot::HyraxDashboardControllerDecorator)

  # We're using an older version of the FITSServlet tool (1.1.3 as of 2019-12-03,
  # anything higher throws an exception that I can't nail down) that predates
  # a change to set the response encoding to UTF-8. So we need to do this as
  # early as possible within the Characterization tool.
  module Spot
    module FitsServletCharacterizerDecorator
      extend ActiveSupport::Concern

      # Wrap the datafile= param in quotes to handle filenames with spaces
      def command
        %(curl -k -F datafile=@"#{filename}" #{ENV['FITS_SERVLET_URL']}/examine)
      end

      def output
        super.encode('UTF-8', invalid: :replace)
      end
    end
  end

  Hydra::FileCharacterization::Characterizers::FitsServlet.prepend(Spot::FitsServletCharacterizerDecorator)

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
  module Spot
    module EmbargoActiveDecorator
      extend ActiveSupport::Concern

      def active?
        embargo_release_date.present? && DateTime.current < embargo_release_date
      end
    end

    module LeaseActiveDecorator
      extend ActiveSupport::Concern

      def active?
        lease_expiration_date.present? && DateTime.current < lease_expiration_date
      end
    end
  end

  Hydra::AccessControls::Embargo.prepend(Spot::EmbargoActiveDecorator)
  Hydra::AccessControls::Lease.prepend(Spot::LeaseActiveDecorator)

  # Updating how SimpleForm generates labels so that we can use the same locales
  # for the form as those for the metadata display.
  module Spot
    module SimpleFormBaseInputDecorator
      extend ActiveSupport::Concern

      protected def raw_label_text
        options[:label] || I18n.t("blacklight.search.fields.#{attribute_name}", default: label_translation)
      end
    end
  end

  SimpleForm::Inputs::Base.prepend(Spot::SimpleFormBaseInputDecorator)

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
  module Spot
    module CollectionMemberSearchBuilderDecorator
      extend ActiveSupport::Concern

      def add_sorting_to_solr(solr_parameters)
        return if solr_parameters[:q]
        solr_parameters[:sort] ||= (sort || "title_sort_si asc")
      end
    end
  end

  Hyrax::CollectionMemberSearchBuilder.prepend(Spot::CollectionMemberSearchBuilderDecorator)

  # Hyrax::AdminSetCreateService.singleton_class.send(:prepend, Spot::AdminSetCreateServiceDecorator)

  # Only store entitlements related to us in the session to prevent a cookie overflow.
  #
  # @see https://github.com/biola/rack-cas/blob/v0.16.1/lib/rack/cas.rb#L96-L102
  # rubocop:disable Style/IfUnlessModifier
  module Spot
    module RackCasEntitlementDecorator
      extend ActiveSupport::Concern

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
  end

  require 'rack/cas' unless Object.const_defined?('Rack::RAS')

  Rack::CAS.prepend(Spot::RackCasEntitlementDecorator)

  # Modifying how Questiong Authority returns AssignFAST results by
  # converting fst ids into URLs
  module Spot
    module QaAssignFastGenericAuthorityDecorator
      extend ActiveSupport::Concern

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
  end

  Qa::Authorities::AssignFast::GenericAuthority.prepend(Spot::QaAssignFastGenericAuthorityDecorator)

  module Spot
    module QaAssignFastSubauthorityDecorator
      extend ActiveSupport::Concern

      def index_for_authority(authority)
        return authority if authority == 'idroot'

        Qa::Authorities::AssignFastSubauthority::SUBAUTHORITIES[authority]
      end

      def subauthorities
        Qa::Authorities::AssignFastSubauthority::SUBAUTHORITIES.keys + ['idroot']
      end
    end
  end

  # In order for us to search assignFAST by FAST IDs, we need to
  # add the 'idroot' searchIndex as a valid subauthority for AssignFast
  Qa::Authorities::AssignFastSubauthority.prepend(Spot::QaAssignFastSubauthorityDecorator)

  # Modifying the Video Runner for Hydra to use a customized Processor
  # which backports changes from 3.8.0
  #
  # @see https://github.com/samvera/hydra-derivatives/blob/v3.8.0/lib/hydra/derivatives/runners/video_derivatives.rb

  module Spot
    module VideoProcessorClassDecorator
      extend ActiveSupport::Concern

      class_methods do
        def processor_class
          Spot::VideoProcessor
        end
      end
    end
  end

  Hydra::Derivatives::VideoDerivatives.prepend(Spot::VideoProcessorClassDecorator)

  # Add original file names and the transcript flag to presenter for file sets
  #
  # @see https://github.com/samvera/hyrax/blob/e4f8a06aaf1c9ec378f87764da59f73a8adf06d7/app/presenters/hyrax/file_set_presenter.rb
  module Spot
    module FileSetPresenterDecorator
      extend ActiveSupport::Concern

      prepended do
        delegate :original_filenames, :transcript_name,
                 :stored_derivatives, to: :solr_document
      end
    end
  end

  Hyrax::FileSetPresenter.prepend(Spot::FileSetPresenterDecorator)

  # Add support for downloading file_set transcripts
  Hyrax::DownloadsController.prepend(Spot::DownloadsControllerBehavior)

  # Modifying Bulkrax ImporterJob so that it correctly fetches file sizes
  #
  # @see https://github.com/samvera/bulkrax/blob/v5.5.1/app/parsers/bulkrax/csv_parser.rb#L258
  #
  module Spot
    module BulkraxImporterJobDecorator
      extend ActiveSupport::Concern
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
  end

  Bulkrax::ImporterJob.prepend(Spot::BulkraxImporterJobDecorator)

  # Bulkrax's parser replaces any whitespace character with a space, which kills paragraph breaks
  # and newlines. Our patch modifies the base #result method to only replace tabs with
  # spaces and strip lead/trailing spaces.
  #
  # A secondary patch adds an s3 files matcher to remotely import files without the Browse
  # Everything UI.
  #
  # @see app/services/concerns/spot/bulkrax_matcher_whitespace_patch.rb
  # @see app/services/concerns/spot/bulkrax_s3_files_matcher.rb
  # @see spec/matchers/bulkrax/application_matcher_spec.rb
  Bulkrax::ApplicationMatcher.prepend(Spot::BulkraxMatcherWhitespacePatch)
  Bulkrax::ApplicationMatcher.prepend(Spot::BulkraxS3FilesMatcher)

  # Modifying the Downloads Controller to not send an unauthorized status for requests.
  # The unauthorized status breaks the laf only thumbnail.
  #
  # @see https://github.com/samvera/hyrax/blob/hyrax-v3.6.0/app/controllers/hyrax/downloads_controller.rb#L52-L63
  module Spot
    module HyraxDownloadsControllerDecorator
      extend ActiveSupport::Concern
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
  end

  Hyrax::DownloadsController.prepend(Spot::HyraxDownloadsControllerDecorator)

  # Encountering an issue where Hyrax::PersistDirectlyContainedOutputFileService.retrieve_file_set requires
  # Hyrax::UploadedFile#file_set_uri to be an URI but querying for that URI throws an error (ActiveFedora
  # is appending the base root to the full uri, resulting in errors like:
  #     Ldp::BadRequest: Path contains empty element! /dev/ht/tp/:/http://fedora:8080/rest/dev/2v/23/vt/36/2v23vt362")
  # module Spot
  #   module HyraxUploadedFileDecorator
  #     def add_file_set!(file_set)
  #       uri = case file_set
  #             when ActiveFedora::Base
  #               file_set.uri
  #             when Hyrax::Resource
  #               file_set.id.is_a?(URI::HTTP) ? file_set.id : Hyrax::Base.id_to_uri(file_set.id.to_s)
  #             end

  #       update!(file_set_uri: uri) if uri.present?
  #     end
  #   end
  # end

  # Hyrax::UploadedFile.prepend(Spot::HyraxUploadedFileDecorator)

  # Changing the call to open to URI.open because exporters could not find files from URIs otherwise
  #
  # see @https://github.com/samvera/bulkrax/blob/5e85a0760e9cc317ae11dbecd35c508d6882a5b6/app/parsers/bulkrax/csv_parser.rb
  # rubocop:disable all
  module Spot
    module BulkraxCsvParserDecorator
      extend ActiveSupport::Concern
      def store_files(identifier, folder_count)
        record = Bulkrax.object_factory.find(identifier)
        return unless record

        file_sets = Array.wrap(record) if record.file_set?
        if file_sets.nil? # for valkyrie
          file_sets = record.respond_to?(:file_sets) ? record.file_sets : record.members&.select(&:file_set?)
        end

        if importerexporter.include_thumbnails?
          thumbnail = Bulkrax.object_factory.thumbnail_for(resource: record)
          file_sets << thumbnail if thumbnail.present?
        end

        file_sets.each do |fs|
          path = File.join(exporter_export_path, folder_count, 'files')
          FileUtils.mkdir_p(path) unless File.exist? path

          original_file = Bulkrax.object_factory.original_file(fileset: fs)
          next if original_file.blank?
          file = filename(fs)

          io = original_file.respond_to?(:uri) ? URI.open(original_file.uri) : original_file.file.io

          File.open(File.join(path, file), 'wb') do |f|
            f.write(io.read)
            f.close
          end
        end
      rescue Ldp::Gone
        return
      rescue StandardError => e
        raise StandardError, "Unable to retrieve files for identifier #{identifier} - #{e.message}"
      end
    end
  end
  # rubocop:enable all

  Bulkrax::CsvParser.prepend(Spot::BulkraxCsvParserDecorator)

  # Copied over from Hyrax to overwrite the method in the user concern.
  # We remove the password parameter since we don't use it.
  #
  # @see https://github.com/samvera/hyrax/blob/0af11acf9088cc90c7c9dcf2b4969bd45a101fe2/app/models/concerns/hyrax/user.rb#L183C5-L185C8
  Hyrax::User.class_eval do
    def find_or_create_system_user(user_key)
      User.find_by_user_key(user_key) || User.create!(user_key_field => user_key)
    end
  end
end
