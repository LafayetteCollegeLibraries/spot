# frozen_string_literal: true
module Spot
  class EdtfDateValidator < ::ActiveModel::Validator
    # @todo "DEPRECATION WARNING: Calling `<<` to an ActiveModel::Errors message array in order to add an error is deprecated.
    #        Please call `ActiveModel::Errors#add` instead."
    # @see https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-add
    def validate(record)
      fields = Array.wrap(options[:fields] || options[:field])
      fields.each do |field|
        Array.wrap(record.send(field)).compact.each do |value|
          record.errors[field] << invalid_edtf_value_message(value) if Date.edtf(value).nil?
        end
      end
    end

    private

    def invalid_edtf_value_message(value)
      "\"#{value}\" is not a valid EDTF date value."
    end
  end
end
