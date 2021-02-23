# frozen_string_literal: true
module Spot
  module CatalogHelper
    # Used in CatalogController to humanize date values on catalog#index results displays.
    # Falls back to the original value.
    #
    # @return [String]
    # rubocop:disable Style/RescueModifier
    def humanize_edtf_values(args)
      Array.wrap(args[:value]).map { |value| Date.edtf(value).humanize rescue value }.to_sentence
    end
    # rubocop:enable Style/RescueModifier

    def display_info_alert?(document)
      return true if document.embargo_release_date.present? || document.lease_expiration_date.present? || document.registered?
      false
    end
  end
end
