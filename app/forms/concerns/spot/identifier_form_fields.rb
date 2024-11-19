# frozen_string_literal: true
module Spot
  # Mixin to add support for separate standard/local identifier form fields.
  module IdentifierFormFields
    extend ActiveSupport::Concern

    included do
      class_attribute :identifier_field, default: :identifier

      property :local_identifier,
               virtual: true,
               prepopulator: ->(_opts) { self.local_identifier = local_identifiers.map(&:to_s) }

      property :standard_identifier_prefix,
               virtual: true,
               prepopulator: ->(_opts) { self.standard_identifier_prefix = standard_identifiers.map(&:prefix) }
      property :standard_identifier_value,
               virtual: true,
               prepopulator: ->(_opts) { self.standard_identifier_value = standard_identifiers.map(&:value) }

      validate(identifier_field) do
        send(:"#{identifier_field}=", merged_identifiers)
      end
    end

    def local_identifiers
      wrapped_identifiers.select(&:local?).reject { |id| id.prefix == 'noid' }
    end

    def merged_identifiers
      [
        send(identifier_field),
        merged_standard_identifiers,
        local_identifier
      ].flatten.compact.uniq
    end

    def merged_standard_identifiers
      prefixes = Array.wrap(standard_identifier_prefix)
      values = Array.wrap(standard_identifier_value)
      prefixes.zip(values)
              .flat_map { |(prefix, id)| Spot::Identifier.new(prefix, id).to_s }
              .uniq
    end

    def standard_identifiers
      wrapped_identifiers.select(&:standard?)
    end

    def wrapped_identifiers
      Array.wrap(send(identifier_field)).map { |id| Spot::Identifier.from_string(id) }
    end
  end
end
