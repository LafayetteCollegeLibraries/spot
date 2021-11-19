# frozen_string_literal: true
#
# A concern for adding support for fields that behave like ActiveFedora
# nested properties, but aren't RDF related. A good use case is a property
# that pulls a value from a controlled vocabulary via autocomplete, but
# that vocabulary is controlled locally (ex. via a YAML file with the
# Questioning Authority gem).
#
# Adding this support may also involve updating the
# +app/assets/javascripts/hyrax/autocomplete.es6+ file to change the type
# of Autocomplete function added to the field, as well as the field's edit
# field rendering (at +app/views/records/edit_fields/_<property>.html.erb).
#
# To add support to your form, include this module and call the
# {.transforms_nested_fields_for} macro:
#
# @example
#   class ImageForm < Hyrax::Forms::WorkForm
#     include ::NestedFormFields
#
#     transforms_nested_fields_for :academic_department, :keyword
#   end
module NestedFormFields
  extend ActiveSupport::Concern

  module ClassMethods
    # A macro for storing the fields we'd like to transform. This
    # is called at the class level, preferrably at the top, similar
    # to ActiveRecord macros.
    #
    # @param [Array<Symbol>] *fields fields to transform
    # @return [void]
    def transforms_nested_fields_for(*fields)
      define_singleton_method(:_nested_fields) { fields.flatten }
    end

    # Adds our nested fields to the form's permitted parameters.
    #
    # @return [Array<Symbol, Hash<Symbol => Array>]
    def build_permitted_params
      return super unless respond_to?(:_nested_fields)

      super.tap do |params|
        _nested_fields.each do |field|
          params << { "#{field}_attributes": [:id, :_destroy] }
        end
      end
    end

    # Tapping into the +.model_attributes+ chain to transform
    # our nested fields.
    #
    # @param [ActiveController::Parameters, Hash<String => *>]
    # @return [Hash]
    def model_attributes(form_params)
      super.tap do |params|
        transform_nested_fields!(params)
      end
    end

    private

      # There may be a clearer name for this. Local controlled
      # vocabulary fields are returned to the form looking like
      # +WorkModel.accepts_nested_attributes_for+ properties.
      # However, they're decidedly _not_ ActiveFedora nested
      # attributes and they need to be transformed back.
      #
      # Essentially, we're receiving attributes that look like:
      #
      #   {'language_attributes' => {'0' => { 'id' => 'en' }}}
      #
      # and transforming them to look like:
      #
      #   {'language' => ['en']}
      #
      # Note that this step isn't necessary if we're
      # just using the jquery-ui autocomplete field type.
      #
      # @param [ActionController::Parameters, Hash] params
      # @return [ActionController::Parameters, Hash]
      def transform_nested_fields!(params)
        return unless respond_to?(:_nested_fields)

        _nested_fields.each do |field_key|
          field = params.delete("#{field_key}_attributes")
          next if field.nil?

          params[field_key] = transform_nested_values(field.values)
        end
      end

      # flattens nested_attribute values into an array of
      # ids. if the +_destroy+ key is present, the field
      # is skipped, removing it from the record.
      #
      # @param [ActionController::Parameters,Hash] params
      # @param [Symbol,String] field_key
      # @return [Array<String>]
      def transform_nested_values(values)
        return [] if values.empty?

        values.map do |value|
          next unless value['_destroy'].blank?
          value['id'] if value['id']
        end.compact
      end
  end
end
