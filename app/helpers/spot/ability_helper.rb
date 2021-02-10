# frozen_string_literal: true
module Spot
  module AbilityHelper
    # Overrides Hyrax::AbilityHelper#visibility_options by adding an +:all+ variant that
    # returns all of the options
    def visibility_options(variant)
      options = [
        Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
        Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED,
        Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
      ]
      case variant
      when :restrict
        options.delete_at(0)
        options.reverse!
      when :loosen
        options.delete_at(2)
      end
      options.map { |value| [visibility_text(value), value] }
    end
  end
end
