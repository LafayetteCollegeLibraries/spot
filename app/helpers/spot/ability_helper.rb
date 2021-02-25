# frozen_string_literal: true
module Spot
  module AbilityHelper
    # Select options for visibility. Overwriting the original method to add our metadata-only
    # visibility as an option.
    #
    # @return [Array<Array<String, String>>]
    def visibility_options(variant)
      options = [
        Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
        'metadata',
        Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED,
        Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
      ]

      case variant
      when :restrict
        options.delete_at(0)
        # options.reverse!
      when :loosen
        options.delete_at(2)
      end
      options.map { |value| [visibility_text(value), value] }
    end
  end
end
