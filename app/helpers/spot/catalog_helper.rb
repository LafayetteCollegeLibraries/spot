# frozen_string_literal: true
module Spot
  module CatalogHelper
    # Used in CatalogController to humanize date values on catalog#index results displays.
    # Falls back to the original value.
    #
    # @return [String]
    def humanize_edtf_values(args)
      Array.wrap(args[:value]).map { |val| humanize_edtf_value(val) }.to_sentence
    end

    def humanize_edtf_value(value)
      Date.edtf(value).humanize
    rescue
      value
    end
  end
end
