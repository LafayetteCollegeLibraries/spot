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

  def site_last_updated
    @site_last_updated ||= begin
      if Rails.env.production?
        pwd = File.basename(Dir.pwd)
        date = begin
                 Date.parse(pwd)
               rescue
                 Time.zone.now
               end
        date.strftime('%Y-%m-%d')
      else
        'Not in production environment'
      end
    end
  end
end
