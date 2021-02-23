# frozen_string_literal: true
module ApplicationHelper
  delegate :advanced_search_path, to: :blacklight_advanced_search_engine

  # @return [String]
  def browse_collections_path
    search_catalog_path(f: { has_model_ssim: ['Collection'] })
  end

  # @param [SolrDocument] document
  # @return [Array<String>]
  def extracted_text_highlight_values_for(document)
    return [] unless document.has_highlight_field? 'extracted_text_tsimv'
    document.highlight_field('extracted_text_tsimv').reject(&:blank?)
  end

  def metadata_only_display_html(document)
    key = if document.embargo_release_date.present?
            'embargo_html'
          elsif document.lease_expiration_date.present?
            'lease_html'
          elsif document.registered?
            'authenticated_html'
          else
            # we shouldn't be getting here, but if we do, it's just a blanket "private" message
            'private_html'
          end

    args = { scope: ['spot', 'access_message'], default: "This item's files are unavailable to view." }
    args[:date] = document.embargo_release_date.strftime('%B %e, %Y') if key == 'embargo'
    args[:date] = document.lease_expiration_date.strftime('%B %e, %Y') if key == 'lease'

    I18n.t("#{key}_html", **args)
  end
end
