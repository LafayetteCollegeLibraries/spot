# frozen_string_literal: true
Rails.application.config.to_prepare do
  # Spot overrides Hyrax
  Hyrax::Dashboard::CollectionsController.presenter_class = Spot::CollectionPresenter
  Hyrax::Dashboard::CollectionsController.form_class = Spot::Forms::CollectionForm

  Hyrax::CollectionsController.presenter_class = Spot::CollectionPresenter
  Hyrax::CollectionsController.include Spot::CollectionSlugsBehavior

  Hyrax::DerivativeService.services = [
    ::Spot::ImageDerivativesService,
    ::Hyrax::FileSetDerivativesService
  ]

  # see above
  Hyrax::ContactFormController.class_eval { layout 'hyrax/1_column' }

  # the dashboard/my/collections (+ thus, dashboard/collections) controller defines
  # blacklight facets + uses I18n.t to provide a label. as we've found from past experience,
  # this can get called _before_ all of the locales are loaded, resulting in a
  # "translation missing" message being provided as a fall-back label. this should
  # prevent that error from appearing by replacing the +translate+ calls with a symbolized
  # I18n key (see also 0717dee, + catalog_controller.rb)
  Hyrax::My::CollectionsController.class_eval do
    def self.update_facet_labels
      blacklight_config.facet_fields['visibility_ssi'].label = :'hyrax.dashboard.my.heading.visibility'
      blacklight_config.facet_fields[Collection.collection_type_gid_document_field_name].label = :'hyrax.dashboard.my.heading.collection_type'
      blacklight_config.facet_fields['has_model_ssim'].label = :'hyrax.dashboard.my.heading.collection_type'
    end
    update_facet_labels
  end

  # We're using an older version of the FITSServlet tool (1.1.3 as of 2019-12-03,
  # anything higher throws an exception that I can't nail down) that predates
  # a change to set the response encoding to UTF-8. So we need to do this as
  # early as possible within the Characterization tool.
  require 'hydra-file_characterization'

  Hydra::FileCharacterization::Characterizers::FitsServlet.class_eval do
    def output
      super.encode('UTF-8', invalid: :replace)
    end
  end

  # Add our SolrSuggestActor to the front of the default actor-stack. This will
  # trigger a build of all of the Solr suggestion dictionaries at the end of
  # each create, update, destroy process (each method calls the next actor and _then_
  # enqueues the job).
  Hyrax::CurationConcern.actor_factory.unshift(SolrSuggestActor)
end
