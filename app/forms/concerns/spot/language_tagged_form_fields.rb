# frozen_string_literal: true
module Spot
  # Adds support for adding a language tag to a value within the form. This is done
  # by creating virtual "_value" and "_language" fields in the form, parsed from RDF::Literals,
  # and merging them when the form is submitted. Include using the method invocation and pass
  # the field names.
  #
  # @example
  #   class WorkResourceForm < ::Hyrax::Forms::ResourceForm(WorkResource)
  #     include Hyrax::FormFields(:metadata_schema)
  #     include Spot::LanguageTaggedFormFields(:title, :title_alternative)
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
      # yilds the original values for processing and returns the updated value(s)
      #
      # @param [Hash] options
      # @option [#to_sym] field
      # @return [void]
      def process_field_values(field:)
        processed = Array.wrap(send(field.to_sym)).map do |original_value|
          yield original_value
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
        literals = values.zip(languages).map { |(value, language)| RDF::Literal(value, language: language&.to_sym) unless value.empty? }

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
        default_value = descendant.definitions[field.to_s][:default].call
        val_prepopulator = ->(_opts) { send(:"#{field}_value=", language_tagged_values_for(field: field)) }
        lang_prepopulator = ->(_opts) { send(:"#{field}_language=", language_tagged_languages_for(field: field)) }

        descendant.property(:"#{field}_value", virtual: true, default: default_value, prepopulator: val_prepopulator)
        descendant.property(:"#{field}_language", virtual: true, default: default_value, prepopulator: lang_prepopulator)

        # @todo perform presence check if the field is required?
        descendant.validate(field) do
          send(:"#{field}=", language_tagged_literals_for(field: field))
        end
      end
    end
  end
end
