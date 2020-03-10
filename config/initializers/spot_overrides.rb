# frozen_string_literal: true
#
# Class attribute updates + monkey-patching required to get Hyrax/etc
# acting like we'd like them to. Try to leave some comments to help
# yourself out. Sincerely, you from the future.
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

  # Here we'll hide the Image model from the 'Create work' modal picker
  # until we've reached a point where we're ready to have users choose
  # the work model. If we try to do this by simply removing the model
  # from the registered curation_concerns (in the Hyrax initializer),
  # we lose out on being able to dynamically generate URLs for permalinks.
  #
  # @see https://github.com/samvera/hyrax/blob/v2.6.0/app/presenters/hyrax/select_type_list_presenter.rb#L20
  # @see https://github.com/samvera/hyrax/blob/v2.6.0/app/services/hyrax/quick_classification_query.rb
  Hyrax::QuickClassificationQuery.class_eval do
    def models
      @models - ['Image']
    end
  end

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
end
