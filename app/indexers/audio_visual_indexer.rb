# frozen_string_literal: true
class AudioVisualIndexer < BaseIndexer
  self.sortable_date_property = :date

  # @return [Hash<String => *>]
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['stored_derivatives_ssim'] ||= []
    end
  end
end
