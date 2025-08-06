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

  # Change the layout used for pages and the contact form
  Hyrax::ContactFormController.prepend(Spot::OneColumnLayout)
  Hyrax::PagesController.prepend(Spot::OneColumnLayout)

  # Update the dashboard labels for collections
  #
  # @see app/controllers/concerns/spot/updated_collections_dashboard_collection_facets_behavior.rb
  Hyrax::My::CollectionsController.prepend(Spot::UpdatedCollectionsDashboardControllerFacetsBehavior)
  Hyrax::Dashboard::CollectionsController.prepend(Spot::UpdatedCollectionsDashboardControllerFacetsBehavior)

  # Update the dashboard labels for collections
  #
  # @see app/controllers/concerns/spot/updated_works_dashboard_collection_facets_behavior.rb
  Hyrax::My::WorksController.prepend(Spot::UpdatedWorksDashboardControllerFacetsBehavior)
  Hyrax::Dashboard::WorksController.prepend(Spot::UpdatedWorksDashboardControllerFacetsBehavior)

  # We're using an older version of the FITSServlet tool (1.1.3 as of 2019-12-03,
  # anything higher throws an exception that I can't nail down) that predates
  # a change to set the response encoding to UTF-8. So we need to do this as
  # early as possible within the Characterization tool.
  #
  # @note as of 2025-04-29, is thi sstill necessary?
  # require 'hydra-file_characterization'

  # Hydra::FileCharacterization::Characterizers::FitsServlet.class_eval do
  #   # Wrap the datafile= param in quotes to handle filenames with spaces
  #   def command
  #     %(curl -k -F datafile=@"#{filename}" #{ENV['FITS_SERVLET_URL']}/examine)
  #   end

  #   def output
  #     super.encode('UTF-8', invalid: :replace)
  #   end
  # end

  # Add our SolrSuggestActor to the front of the default actor-stack. This will
  # trigger a build of all of the Solr suggestion dictionaries at the end of
  # each create, update, destroy process (each method calls the next actor and _then_
  # enqueues the job).
  #
  # @todo remove with ActorStack
  Hyrax::CurationConcern.actor_factory.unshift(SolrSuggestActor)

  # Updating how SimpleForm generates labels so that we can use the same locales
  # for the form as those for the metadata display.
  #
  # @todo is this still needed?
  SimpleForm::Inputs::Base.class_eval do
    protected def raw_label_text
      options[:label] || I18n.t("blacklight.search.fields.#{attribute_name}", default: label_translation)
    end
  end

  # Define this constant, intended to be similar to AdminSet::DEFAULT_ID
  AdminSet::STUDENT_WORK_ID = Spot::StudentWorkAdminSetCreateService::ADMIN_SET_ID

  # Our own Characterization Service subclass that uses :fits_servlet by default
  CharacterizeJob.characterization_service = Spot::CharacterizationService

  # Override the Browse-Everything Retreiver to take S3 URIs
  # @see app/services/concerns/spot/retrieves_s3_urls.rb
  BrowseEverything::Retriever.prepend(Spot::RetrievesS3Urls)
  BrowseEverything::Retriever.class_eval do
    class << self
      prepend Spot::RetrievesS3Urls::ClassMethods
    end
  end

  # # To be honest, I'm not sure why the Hyrax code doesn't work as-is,
  # # but rewriting the solr_params[:sort] assignment to this kinda
  # # wonky one-liner seems to preserve user-selected sorting. ¯\_(ツ)_/¯
  # #
  # # @see https://github.com/samvera/hyrax/blob/main/app/search_builders/hyrax/collection_search_builder.rb#L36-L42
  # Hyrax::CollectionMemberSearchBuilder.class_eval do
  #   def add_sorting_to_solr(solr_parameters)
  #     return if solr_parameters[:q]
  #     solr_parameters[:sort] ||= (sort || "title_sort_si asc")
  #   end
  # end

  # Only store entitlements related to us in the session to prevent a cookie overflow.
  #
  # @see app/controllers/concerns/spot/cas_entitlement_patch_rack.rb
  # @see https://github.com/biola/rack-cas/blob/v0.16.1/lib/rack/cas.rb#L96-L102
  #
  # @note is this needed with Rails.application.config.rack_cas.extra_attributes_filter ?
  require 'rack/cas'
  Rack::CAS.prepend(Spot::CasEntitlementPatchRack)

  # Modifying how Questiong Authority returns AssignFAST results by
  # converting fst ids into URLs
  #
  # @see app/authorities/concerns/spot/qa_assign_fast_generic_authority_patch.rb
  Qa::Authorities::AssignFast::GenericAuthority.prepend(Spot::QaAssignFastGenericAuthorityPatch)

  # In order for us to search assignFAST by FAST IDs, we need to
  # add the 'idroot' searchIndex as a valid subauthority for AssignFast
  #
  # @see app/authorities/concerns/spot/qa_assign_fast_subauthority_patch.rb
  Qa::Authorities::AssignFastSubauthority.prepend(Spot::QaAssignFastSubauthorityPatch)

  # Add original file names and the transcript flag to presenter for file sets
  #
  # @see app/presenters/concerns/spot/file_set_presenter_additions.rb
  # @see https://github.com/samvera/hyrax/blob/e4f8a06aaf1c9ec378f87764da59f73a8adf06d7/app/presenters/hyrax/file_set_presenter.rb
  Hyrax::FileSetPresenter.include(Spot::FileSetPresenterAdditions)

  # Add support for downloading file_set transcripts
  # @see app/controllers/concerns/spot/downloads_controller_behavior
  Hyrax::DownloadsController.prepend(Spot::DownloadsControllerBehavior)

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

  # ValkyrieIngestJob.class_eval do
  #   def ingest(file:, pcdm_use:)
  #     file_set_id = Valkyrie::ID.new(Hyrax::Base.uri_to_id(file.file_set_uri))
  #     file_set = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: file_set_id)

  #     upload_file(
  #       file: file,
  #       file_set: file_set,
  #       pcdm_use: pcdm_use,
  #       user: file.user
  #     )
  #   end
  # end

  # Likely to not be needed once we're fully Valkyrized.
  #
  # @see app/forms/concerns/spot/batch_edit_form_terms_and_permitted_params.rb
  Hyrax::Forms::BatchEditForm.include(Spot::Forms::BatchEditFormTermsAndPermittedParams)
  # Hyrax::Forms::BatchEditForm.prepend(Spot::Forms::BatchEditFormTermsAndPermittedParams)
  # Hyrax::Forms::BatchEditForm.class_eval do
  #   class << self
  #     prepend Spot::Forms::BatchEditFormTermsAndPermittedParams::ClassMethods
  #   end
  # end

  Hyrax::PcdmMemberPresenterFactory.prepend(Spot::LucenePatchForPcdmMemberPresentersFactory)
end
