# frozen_string_literal: true
#
# Provides helper methods that are defined at the Controller level
module ControllerHelpers
  module ControllerLevelHelpers
    def blacklight_config
      @blacklight_config ||= CatalogController.blacklight_config
    end
  end

  # Borrowed from
  # https://github.com/samvera/hyrax/blob/5a9d1be16ee1a9150646384471992b03aab527a5/spec/support/controller_level_helpers.rb#L24-L26
  #
  # Allows us to add the helpers to the context
  def initialize_controller_helpers(ctx)
    ctx.extend(ControllerLevelHelpers)
  end
end
