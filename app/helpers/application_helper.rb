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

  # @return [String] HTML of bootstrap alert with text
  def document_access_display_alert(document)
    key = if document.embargo_release_date.present?
            :embargo
          elsif document.lease_expiration_date.present?
            :lease
          elsif document.registered?
            :authenticated
          else
            # we shouldn't be getting here, but if we do, it's just a blanket "private" message
            :private
          end

    args = { scope: ['spot', 'work', 'access_message'], default: "This item's files are currently unavailable." }
    args[:date] = document.embargo_release_date.strftime('%B %e, %Y')  if key == :embargo
    args[:date] = document.lease_expiration_date.strftime('%B %e, %Y') if key == :lease

    %(<div class="alert alert-warning" style="margin:0; padding: 5px;">#{I18n.t(key, **args)}</div>).html_safe
  end
end
