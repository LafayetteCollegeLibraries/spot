# frozen_string_literal: true
#
# A concern for adding language-tagged fields to your +hydra-editor+-based
# form object. Abstracts away the addition of the defined fields to the
# permitted parameters array as well as transforming the form values back
# to something the object itself understands. To add support, include this
# module into your form and call the {.transforms_language_tags_for} macro:
#
# @example
#   class ImageForm < Hyrax::Forms::WorkForm
#     include ::LanguageTaggedFormFields
#
#     transforms_language_tags_for :title, :description
#   end
module LanguageTaggedFormFields
  extend ActiveSupport::Concern

  module ClassMethods
    # A macro for storing the fields we wish to transform. This needs to
    # be called at the class level so that the fields can be stored in
    # a singleton method to be called later.
    #
    # @todo is there a better way to do this? my meta-programming naivity
    #       might be showing?
    # @param *fields [Array<Symbol>] The fields to transform
    # @return [void]
    def transforms_language_tags_for(*fields)
      define_singleton_method(:language_tagged_fields) { fields.flatten }
    end

    # Adds two fields to the form object's permitted parameters:
    # +field_value+ and +field_language+, where one is expected to be
    # property value and the other is the language tag (if present).
    # Uses the form's +#multiple?# method to determine whether symbols
    # or a hash goes into the object.
    #
    # @return [Array<Symbol,Hash<Symbol => Array>>]
    def build_permitted_params
      params = super
      return params unless respond_to?(:language_tagged_fields)

      language_tagged_fields.each do |field|
        field_params = { "#{field}_value": [], "#{field}_language": [] }

        if multiple?(field)
          params << field_params
        else
          params += field_params.keys
        end
      end

      params
    end

    # Calls our transformation method as part of the chain of
    # {.model_attributes} calls.
    #
    # @param form_params [ActiveController::Parameters, Hash<String => *>]
    # @return [Hash]
    def model_attributes(form_params)
      super.tap do |params|
        transform_language_tagged_fields!(params)
      end
    end

  private

    # transforms arrays of field values + languages into serialized RDF::Literals
    # tagged with said language
    #
    # @param params [ActiveController::Parameters, Hash<String => Array<String>>]
    # @return [void]
    def transform_language_tagged_fields!(params)
      return unless respond_to?(:language_tagged_fields)

      language_tagged_fields.flatten.each do |field|
        value_key = "#{field}_value"
        lang_key = "#{field}_language"

        next unless params.include?(value_key) && params.include?(lang_key)

        values = Array(params.delete(value_key))
        langs = Array(params.delete(lang_key))

        mapped = map_rdf_strings(values.zip(langs))

        params[field] = mapped if mapped
        params[field] = params[field].first unless multiple?(field)
      end
    end

    # Transforms an array of value/language pairs into serialized literals
    #
    # @param tuples [Array<Array<String>>]
    # @return [Array<String>]
    def map_rdf_strings(tuples)
      tuples.map do |(value, language)|
        # need to skip blank entries here, otherwise we get a blank literal
        # (""@"") which LDP doesn't like
        next unless value.present?

        language = language.present? ? language.to_sym : nil
        serializer.serialize(RDF::Literal(value, language: language))
      end.reject(&:blank?)
    end

    # @return [RdfLiteralSerializer]
    def serializer
      @serializer ||= RdfLiteralSerializer.new
    end
  end
end
