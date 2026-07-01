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
            values.is_a?(Array) ? values.map { |v| humanize_edtf_value(v) } : humanize_edtf_value(values)
          end
        end
      end
    end

    # run a value through +Date.edtf+, return the +.humanize+ value,
    # and fallback to the value if it's unparseable.
    #
    # @param [String] val
    # @return [String]
    #
    # @todo since we're also utilizing this in Spot::CatalogHelper#humanize_edtf_values
    #       it might be good to find a way to deduplicate.
    def humanize_edtf_value(val)
      Date.edtf(val)
          .humanize
          .gsub(/0{0,3}(\d+)/, '\1') # remove leading zeroes
          .gsub(/-(\d{1,4}[\?\~\%]?)/, '\1 BCE') # convert negative dates to BCE
    rescue
      val
    end
  end
end
