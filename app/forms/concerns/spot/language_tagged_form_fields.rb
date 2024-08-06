# frozen_string_literal: true
module Spot
  # The intention is to treat this like the existing Hyrax::FormFields mixins.
  #
  # @example
  #   module Hyrax
  #     class WorkResourceForm < ::Hyrax::Forsm::ResourceForm(WorkResource)
  #       include Hyrax::FormFields(:metadata_schema)
  #       include Hyrax::LanguageTaggedFormFields(:title, :title_alternative)
  #     end
  #   end
  def self.LanguageTaggedFormFields(*fields)
    Spot::LanguageTaggedFormFields.new(*fields)
  end

  class LanguageTaggedFormFields < Module
    # Methods called from within the :prepopulator and :validate
    module HelperMethods
      # Extract the strings of field values that include RDF::Literals.
      # Return value depends on the field's configuration for :multiple.
      #
      # @param [Hash] options
      # @option [String] field
      #   Form field to process
      # @return [Array<String>, String]
      def language_tagged_values_for(field:)
        process_field_values(field: field) do |original|
          case original
          when RDF::Literal
            original.value.to_s
          else
            original
          end
        end
      end

      # Extract the languages of field values that are RDF::Literals.
      # Return value depends on the field's configuration for :multiple.
      #
      # @param [Hash] options
      # @option [String] field
      #   Form field to process
      # @return [Array<String>, String]
      def language_tagged_languages_for(field:)
        process_field_values(field: field) do |original|
          case original
          when RDF::Literal
            original.language.to_s
          end
        end
      end

      # Helper method for the helper methods (lol).
      def process_field_values(field:, &block)
        processed = Array.wrap(self.send(field.to_sym)).map do |original_value|
          block.call(original_value)
        end

        self.class.definitions[field.to_s][:multiple] ? processed : processed.first
      end

      # Merges field _value and _language form values into language-tagged RDF::Literals.
      # Return value depends on the field's configuration for :multiple.
      #
      # @param [Hash] options
      # @option [String] field
      #   Form field to process
      # @return [Array<RDF::Literal>, RDF::Literal]
      def language_tagged_literals_for(field:)
        multiple = self.class.definitions[field.to_s][:multiple]

        values = Array.wrap(send(:"#{field}_value"))
        languages = Array.wrap(send(:"#{field}_language"))
        literals = values.zip(languages).map { |(value, language)| RDF::Literal(value, language: language&.to_sym) }

        multiple ? literals : literals.first
      end
    end

    def initialize(*fields)
      @fields = fields.flatten
    end

    private

    def included(descendant)
      super

      descendant.include(HelperMethods)

      @fields.map(&:to_sym).each do |field|
        default_value = descendant.definitions[field.to_s][:multiple] ? [] : nil

        descendant.property(:"#{field}_value", virtual: true, default: default_value, prepopulator: ->(_opts) {
          self.send(:"#{field}_value=", language_tagged_values_for(field: field))
        })

        descendant.property(:"#{field}_language", virtual: true, default: default_value, prepopulator: ->(_opts) {
          self.send(:"#{field}_language=", language_tagged_languages_for(field: field))
        })

        # @todo perform presence check if the field is required?
        descendant.validate(field) do
          self.send(:"#{field}=", language_tagged_literals_for(field: field))
        end
      end
    end
  end
end
