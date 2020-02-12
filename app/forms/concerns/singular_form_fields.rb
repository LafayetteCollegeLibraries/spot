# frozen_string_literal: true
#
# @example
#   class Hyrax::WorkForm < ::Hyrax::Forms::WorkForm
#     include ::SingularFormFields
#
#     singular_form_fields :title, :creator
#   end
#
module SingularFormFields
  extend ActiveSupport::Concern

  module ClassMethods
    # macro to store singular form fields and define methods to only
    # return the first value of an item (mimicking the field allowing
    # only one value)
    #
    # @param [#to_sym] *fields
    def singular_form_fields(*fields)
      fields = fields.flatten.map(&:to_sym)

      define_method(:_singular_form_fields) { fields }

      fields.each do |field|
        define_method(field.to_sym) { self[field.to_s].first }
      end
    end

    # wraps our singular field values into arrays
    #
    # @param [ActionController::Parameters, Hash] form_params
    # @return [void]
    def model_attributes(form_params)
      super.tap do |params|
        _singular_form_fields.each do |field|
          params[field] = Array.wrap(params[field]) if params[field]
        end
      end
    end

    # @param [#to_sym] field
    # @return [true, false]
    def multiple?(field)
      return super unless respond_to?(:_singular_form_fields)
      return false if _singular_form_fields.include?(field.to_sym)
      super
    end
  end
end
