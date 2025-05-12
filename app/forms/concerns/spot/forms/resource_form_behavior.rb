# frozen_string_literal: true
module Spot
  # Mixin for common form behaviors (in place of a BaseForm object to inherit from)
  module Forms
    module ResourceFormBehavior
      extend ActiveSupport::Concern

      # Hyrax form behavior is to display 'primary' terms above the fold and an 'additional fields'
      # button to expand the rest of the fields. We only use this behavior for non-staff interfaces,
      # and display all of the terms by default.
      #
      # @return [Array<Symbol>]
      def primary_terms
        _form_field_definitions.select { |_, definition| definition[:display] }.keys.map(&:to_sym)
      end

      # By default, keep the 'below the fold' fields empty.
      #
      # @return [Array<Symbol>]
      def secondary_terms
        []
      end
    end
  end
end
