# frozen_string_literal: true
module Spot
  module CatalogHelper
    # Used in CatalogController to humanize date values on catalog#index results displays.
    # Falls back to the original value.
    #
    # @return [String]
    # rubocop:disable Style/RescueModifier
    def humanize_edtf_values(args)
      Array.wrap(args[:value]).map { |value| humanize_edtf_value(value) rescue value }.to_sentence
    end
    # rubocop:enable Style/RescueModifier

    # Should we display an info alert to catalog results?
    #
    # @param [SolrDocument]
    # @return [true, false]
    def display_info_alert?(document)
      return false if document.public?

      document.embargo_release_date.present? ||
        document.lease_expiration_date.present? ||
        document.registered? ||
        document.metadata_only?
    end

    # @param [SolrDocument]
    # @return [String]
    def document_access_display_text(document)
      key = if document.embargo_release_date.present?
              :embargo
            elsif document.lease_expiration_date.present?
              :lease
            elsif document.registered?
              :authenticated
            elsif document.metadata_only?
              :metadata
            else
              :private # not expecting to get here, but we should have a generic message just in case
            end

      date = [:embargo_release_date, :lease_expiration_date].find { |m| (val = document.send(m)).present? && val }
      date = date.strftime('%B %e, %Y') unless date.nil?

      I18n.t("#{key}_html", scope: ['spot', 'work', 'access_message'], default: "This item's files are currently unavailable", date: date)
    end
  end
end
