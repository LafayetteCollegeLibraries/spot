# frozen_string_literal: true
Rails.application.config.to_prepare do
  ## Spot overrides Hyrax

  Hyrax::Dashboard::CollectionsController.presenter_class = Spot::CollectionPresenter
  Hyrax::Dashboard::CollectionsController.form_class = Spot::Forms::CollectionForm

  Hyrax::CollectionsController.presenter_class = Spot::CollectionPresenter
  Hyrax::CollectionsController.include Spot::CollectionSlugsBehavior

  Hyrax::DerivativeService.services = [
    ::Spot::ImageDerivativesService,
    ::Hyrax::FileSetDerivativesService
  ]

  # We've dropped the navbar + banner image that come with Hyrax, and the
  # 'homepage' layout that the PagesController calls defines content for
  # this block. By switching to the 'hyrax' layout (which we're using for
  # the homepage + others), we can drop this component.
  #
  # @todo is there a better way to do this?
  Hyrax::PagesController.class_eval do
    private

      # @return [String]
      def pages_layout
        action_name == 'show' ? 'hyrax' : 'hyrax/dashboard'
      end
  end

  # see above
  Hyrax::ContactFormController.class_eval { layout 'hyrax' }

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
end
