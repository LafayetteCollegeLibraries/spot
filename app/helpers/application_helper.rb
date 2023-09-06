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
    return [] unless document.has_highlight_field?('extracted_text_tsimv')
    document.highlight_field('extracted_text_tsimv').reject(&:blank?)
  end

  # rubocop:disable Style/ClassVars
  # @return [String, nil]
  def site_last_updated
    @@site_last_updated ||= generate_site_last_updated
  end
  # rubocop:enable Style/ClassVars

  # @api private
  def generate_site_last_updated
    return if ENV['SPOT_BUILD_DATE'].blank?
    Date.parse(ENV['SPOT_BUILD_DATE']).strftime('%B %d, %Y')
  rescue
    ENV['SPOT_BUILD_DATE']
  end
end
