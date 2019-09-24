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

  # see above
  Hyrax::ContactFormController.class_eval { layout 'hyrax' }
end
