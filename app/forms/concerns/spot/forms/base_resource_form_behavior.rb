# frozen_string_literal: true
module Spot
  module Forms
    # Since Hyrax 5 forms are inherited from a generated class, this seemed like the easiest way to inject common
    # behavior into forms instead of using a BaseResourceForm class.
    #
    # Adds class method helpers:
    #   - `language_tagged_field(*fields)` for fields stored as RDF::Literals
    #   - `nested_attributes_for(*fields)` for fields using ControlledVocabularies (local and remote)
    #
    # In a bit of opinionated base behavior, this also:
    #   - sets up support for standard/local identifiers if the field :identifier is defined (included with `base_metadata.yml`)
    #   - sets up support for language tagged fields from base_metadata
    #     - :title
    #     - :title_alternative
    #     - :subtitle
    #     - :abstract
    #     - :description
    #   - sets up nested attribute support for controlled vocabulary fields from base_metadata
    #     - :subject
    #     - :location
    #     - :language
    #
    # @example
    #   class GoodResourceForm < Hyrax::Forms::ResourceForm(GoodResource)
    #     include Spot::Forms::BaseResourceFormBehaivor
    #   end
    module BaseResourceFormBehavior
      extend ActiveSupport::Concern

      included do
        # helper method :language_tagged_field
        include Spot::Forms::LanguageTaggedFields

        # helper method :nested_attributes_for
        include Spot::Forms::NestedAttributes

        include Hyrax::FormFields(:core_metadata)
        include Hyrax::FormFields(:base_metadata)

        # form = PublicationResourceForm.for(resource: PublicationResource.new(identifier:['abc:123']))

        if model_class.attribute_names.include?(:identifier)
          # for local_identifier, we exclude the noid: identifier so as to not let it be user-editable.
          property :local_identifier, virtual: true, prepopulator: -> { self.local_identifier = model.local_identifier.reject { |id| id.try(:prefix) == 'noid' }.map(&:to_s) }
          property :standard_identifier, virtual: true, prepopulator: -> { self.standard_identifier = model.standard_identifier.map(&:to_s) }
          property :standard_identifier_prefix, virtual: true, prepopulator: -> { self.standard_identifier_prefix = model.standard_identifier.map(&:prefix) }
          property :standard_identifier_value, virtual: true, prepopulator: -> { self.standard_identifier_value = model.standard_identifier.map(&:value) }

          validate :identifier do
            send(:identifier=, merged_identifiers)
          end
        end

        [:title, :title_alternative, :subtitle, :abstract, :description].each do |field|
          language_tagged_field(field) if model_class.attribute_names.include?(field)
        end

        [:subject, :location, :language].each do |field|
          nested_attributes_for(field) if model_class.attribute_names.include?(field)
        end
      end

      private

      def merged_identifiers
        Array.wrap(standard_identifier_prefix.compact)
             .zip(Array.wrap(standard_identifier_value.compact))
             .flat_map { |(prefix, id)| Spot::Identifier.new(prefix, id).to_s }
             .concat(local_identifier.map(&:to_s))
             .concat(model.identifier.map(&:to_s))
             .flatten
             .compact
             .uniq
      end
    end
  end
end
