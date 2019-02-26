# frozen_string_literal: true
#
# Overrides made directly onto Hyrax classes/code. Essentially
# any modifications you need to make, that aren't solved by
# copying the file locally, should get put here so that it's
# easily found. Stuff like altering class attributes or class_eval.
# Leave comments!
Rails.application.config.after_initialize do
  # Removes the TransactionalRequest from the actor stack, as it's the culprit
  # for the nasty Ldp::Gone errors that happen when an item fails in the
  # actor stack. hyrax#3282 accomplishes the same thing, so this should be
  # on the chopping-block for the hyrax@3 upgrade
  #
  # @todo remove this when upgrading to Hyrax@3
  Hyrax::CurationConcern.actor_factory.delete(Hyrax::Actors::TransactionalRequest)

  # Uses our own CollectionPresenter, which itself is a subclass of the Hyrax one
  Hyrax::CollectionsController.presenter_class = Spot::CollectionPresenter

  # Uses our own CollectionForm, which itself is a subclass of the Hyrax one
  Hyrax::Dashboard::CollectionsController.form_class = Spot::Forms::CollectionForm
end
