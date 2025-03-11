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
    def initialize(*fields)
      @fields = fields.flatten
    end

    private

    def language_prepopulator_for(field:)
      lambda do |_opts|
        vals = Array.wrap(send(field.to_sym)).map do |original|
          case original
          when RDF::Literal
            original.language.to_s
          end
        end.compact

        send(:"#{field}_language=", self.class.definitions[field.to_s][:multiple] ? vals : vals.first)
      end
    end

    def value_prepopulator_for(field:)
      lambda do |_opts|
        vals = Array.wrap(send(field.to_sym)).map do |original|
          case original
          when RDF::Literal
            original.value.to_s
          else
            original
          end
        end.compact

        send(:"#{field}_value=", self.class.definitions[field.to_s][:multiple] ? vals : vals.first)
      end
    end

    def value_populator_for(field:)
      lambda do |doc:, **_opts|
        vals = Array.wrap(doc["#{field}_value"]).zip(Array.wrap(doc["#{field}_language"])).map do |(value, language)|
          if value.present? && language.present?
            RDF::Literal.new(value.to_s, language: language.to_sym)
          elsif value.present?
            RDF::Literal.new(value.to_s)
          end
        end.compact

        vals = vals.first unless self.class.definitions[field.to_s][:multiple]

        send(:"#{field}=", vals)
      end
    end

    def included(descendant)
      super

      @fields.map(&:to_sym).each do |field|
        default_value = descendant.definitions[field.to_s][:default].call
        descendant.property(:"#{field}_value",
                            virtual: true,
                            default: default_value,
                            prepopulator: value_prepopulator_for(field: field),
                            populator: value_populator_for(field: field))
        descendant.property(:"#{field}_language",
                            virtual: true,
                            default: default_value,
                            prepopulator: language_prepopulator_for(field: field))

        descendant.validates(field, presence: true) if descendant.definitions[field.to_s][:required]
      end
    end
  end
end
