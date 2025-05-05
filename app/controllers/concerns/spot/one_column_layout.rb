# frozen_string_literal: true
module Spot
  # Mixin patch for Hyrax controllers that we'd prefer to render as 'hyrax/1_column'
  #
  # @example in initializer
  #   Rails.application.reloader.to_prepare do
  #      Hyrax::PagesController.prepend(Spot::OneColumnLayout)
  #   end
  #
  # @see config/initializers/spot_overrides.rb
  module OneColumnLayout
    extend ActiveSupport::Concern

    included do
      layout 'hyrax/1_column'
    end
  end
end
