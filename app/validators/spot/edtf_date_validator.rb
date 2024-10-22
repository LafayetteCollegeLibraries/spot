# frozen_string_literal: true
module Spot
  class EdtfDateValidator < ::ActiveModel::Validator
    def validate(record)
      fields = Array.wrap(options[:fields] || options[:field])

      fields.each do |field|
        Array.wrap(record.send(field)).each do |value|
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
