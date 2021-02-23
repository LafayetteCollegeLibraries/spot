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
    scope = ['spot', 'access_message']

    if document.embargo_release_date.present?
      key = 'embargo'
    elsif document.lease_expiration_date.present?
      key = 'lease'
    elsif document.visibility == 'authenticated' && !current_ability.can?(:download, document.id)
      key = 'authenticated'
    else
      key = 'private'
    end

    args = { scope: scope, default: [ket, 'This message is unavailable to view.'] }
    date_strftime_args = '%B %e, %Y'

    if key == 'embargo'
      args[:date] = document.embargo_release_date.strftime(date_strftime_args)
    elsif key = 'lease'
      args[:date] = document.lease_expiration_date.strftime(date_strftime_args)
    end

    I18n.t("#{key}_html", **args)
  end
end
