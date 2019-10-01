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
end
