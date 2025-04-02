# frozen_string_literal: true
module Spot
  # Mixin to add support for separate standard/local identifier form fields. We store all identifiers
  # in a single field (typically :identifier) but include prefixes to determine the origin of the value.
  # In the form, we want to split out "standard" identifiers (registered in the Spot::Identifier initializer)
  # with known prefixes from "local" identifiers, which are ad-hoc. This takes care of that splitting and
  # merging work in the form context.
  #
  # @example
  #   class WorkResourceForm < Hyrax::Form(WorkResource)
  #     include Hyrax::FormFields(:work_resource)
  #     include Spot::IdentifierFormFields
  #   end
  #
  #
  # @example To change which field this points to, update the :identifier_field class attribute
  #   class WorkResourceForm < Hyrax::Form(WorkResource)
  #     include Hyrax::FormFields(:work_resource)
  #     include Spot::IdentifierFormFields
  #
  #     self.identifier_field = :external_identifier
  #   end
  #
  module IdentifierFormFields
    extend ActiveSupport::Concern

    included do
      class_attribute :identifier_field, default: :identifier

      property :local_identifier,
               virtual: true,
               display: true,
               prepopulator: -> { self.local_identifier = local_identifiers.map(&:to_s) }

      property :standard_identifier_prefix,
               virtual: true,
               display: true,
               prepopulator: -> { self.standard_identifier_prefix = standard_identifiers.map(&:prefix) }
      property :standard_identifier_value,
               virtual: true,
               display: true,
               prepopulator: -> { self.standard_identifier_value = standard_identifiers.map(&:value) }

      validate(identifier_field) do
        send(:"#{identifier_field}=", merged_identifiers)
      end
    end

    # We store the work's NOID as an identifier, but don't want to allow it to be edited.
    def local_identifiers
      wrapped_identifiers.select(&:local?).reject { |id| id.prefix == 'noid' }
    end
    alias local_identifier local_identifiers

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
    alias standard_identifier standard_identifiers

    def wrapped_identifiers
      Array.wrap(send(identifier_field)).map { |id| Spot::Identifier.from_string(id) }
    end
  end
end
