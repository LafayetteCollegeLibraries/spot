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

  # Going to need to update this once we're fully in the cloud
  def site_last_updated
    @site_last_updated ||= generate_site_last_updated
  end

  # @api private
  def generate_site_last_updated
    return 'Not in production environment' unless Rails.env.production?

    pwd = File.basename(Dir.pwd)
    date = Date.parse(pwd) rescue Time.zone.now

    date.strftime('%B %d, %Y')
  end
end
