# frozen_string_literal: true
module Spot
  module HumanizesDateFields
    extend ActiveSupport::Concern

    module ClassMethods
      # Macro to create instance methods that run the values through +edtf-humanize+
      #
      # @param [Array<Symbol>] *fields
      # @return [void]
      def humanize_date_fields(*fields)
        fields.flatten.each do |field|
          field = field.to_sym

          define_method(field) do
            values = solr_document.send(field)
            values.is_a?(Array) ? values.map { |v| humanize_value(v) } : humanize_value(values)
          end
        end
      end
    end

  private

    # run a value through +Date.edtf+, return the +.humanize+ value,
    # and fallback to the value if it's unparseable.
    #
    # @param [String] val
    # @return [String]
    def humanize_value(val)
      Date.edtf(val).humanize
    rescue
      val
    end
  end
end
