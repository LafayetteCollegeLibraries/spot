# frozen_string_literal: true
require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Spot
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # use sidekiq for async jobs
    config.active_job.queue_adapter = :sidekiq

    config.to_prepare do
      # remove the TransactionalRequest from the actor stack, as it's the culprit
      # for the nast Ldp::Gone errors that happen when an item fails in the
      # actor stack. hyrax#3282 accomplishes the same thing, so this line may
      # be unneccessary in the future (~3.0 upgrade, probably). the class still
      # exists, so we shouldn't encounter a missing constant error.
      Hyrax::CurationConcern.actor_factory.delete(Hyrax::Actors::TransactionalRequest)

      Hyrax::CollectionsController.presenter_class = Spot::CollectionPresenter
      Hyrax::Dashboard::CollectionsController.form_class = Spot::Forms::CollectionForm
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
