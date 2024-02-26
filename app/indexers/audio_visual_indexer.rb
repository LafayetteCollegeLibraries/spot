# frozen_string_literal: true
class AudioVisualIndexer < BaseIndexer
  self.sortable_date_property = :date

  def generate_solr_document
    super.tap do |solr_doc|
      add_oembed_index_data(solr_doc)
    end
  end

  private

  def add_oembed_index_data(_solr_doc)
    return if oembed_url.nil?

    # do some processing
  end

  def oembed_data
    @oembed_data ||= OEmbed::Providers.get(oembed_url) unless oembed_url.nil?
  end

  def oembed_url
    object.try(:embed_url).try(:first)
  end
end
