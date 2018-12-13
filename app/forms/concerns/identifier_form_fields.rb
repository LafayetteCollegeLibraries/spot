# frozen_string_literal: true
#
# A concern for adding a custom identifier field to your hydra-editor form.
# Adds the '_prefix' and '_value' fields to the form's permitted params
# and transforms them back to the single field on submission. Allows
# the customizing of the field name but defaults to +:identifier+.
# To use it, simply include it in your form:
#
# @example
#   class ImageForm < Hyrax::Forms::WorkForm
#     include ::IdentifierFormFields
#   end
module IdentifierFormFields
  extend ActiveSupport::Concern

  included do
    class_attribute :identifier_field
    self.identifier_field = :identifier
  end

  module ClassMethods
    # Adds the _prefix and _value fields to the permitted params
    # array. Will add either a pair of symbols or a hash, depending
    # on how the field responds to +.multiple?+
    #
    # @return [Array<Symbol,Hash<Symbol => Array>>]
    def build_permitted_params
      super.tap do |params|
        if multiple?(identifier_field.to_sym)
          params << {
            identifier_prefix_key => [],
            identifier_value_key => []
          }
        else
          params << identifier_prefix_key
          params << identifier_value_key
        end
      end
    end

    # Calls our transformation method as part of the chain of
    # {.model_attributes} calls.
    #
    # @return [Hash]
    def model_attributes(form_params)
      super.tap do |params|
        transform_identifiers!(params)
      end
    end

    private

      # transforms arrays of identifier prefixes
      # and values into a single array of identifier
      # strings and appends it to +form_params['identifier']+
      #
      # @param [ActiveController::Parameters, Hash] params
      # @return [void]
      def transform_identifiers!(params)
        prefixes = params.delete(identifier_prefix_key.to_s)
        values = params.delete(identifier_value_key.to_s)

        return unless prefixes && values

        mapped = prefixes.zip(values).map do |(key, value)|
          Spot::Identifier.new(key, value).to_s
        end.reject(&:blank?)

        params[identifier_field] = mapped if mapped
      end

      # @return [Symbol]
      def identifier_prefix_key
        :"#{identifier_field}_prefix"
      end

      # @return [Symbol]
      def identifier_value_key
        :"#{identifier_field}_value"
      end
  end
end
