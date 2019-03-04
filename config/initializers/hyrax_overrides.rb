# frozen_string_literal: true
#
# Where possible, we'll try to use the class_attributes provided by the
# various Hyrax pieces to provide our own functionality. However, this
# isn't always possible, and we need to either copy files locally to
# modify or peak into the classes via +class_eval+. Where the latter
# case is necessary, we'll put the file into +app/overrides+ and load
# all of them here, after initialization.
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

  # Load all of our overrides/class_evals
  # (adapted from https://github.com/sciencehistory/chf-sufia/blob/d1c7d58/config/application.rb#L43-L48)
  Dir.glob(Rails.root.join('app', 'overrides', '**', '*.rb')) do |c|
    Rails.configuration.cache_classes ? require(c) : load(c)
  end
end
