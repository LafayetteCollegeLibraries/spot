# frozen_string_literal: true
RSpec.describe AudioVisualIndexer do
  include_context 'indexing'

  it_behaves_like 'a Spot indexer'
  it_behaves_like 'it indexes a sortable date'

  {
    title: %w[tesim],
    subtitle: %w[tesim],
    title_alternative: %w[tesim],
    publisher: %w[tesim sim],
    repository_location: %w[ssim],
    source: %w[tesim sim],
    resource_type: %w[tesim sim],
    physical_medium: %w[tesim sim],
    original_item_extent: %w[tesim],
    description: %w[tesim],
    inscription: %w[tesim],
    creator: %w[tesim sim],
    contributor: %w[tesim sim],
    related_resource: %w[tesim sim],
    date_associated: %w[ssim tesim],
    provenance_derivatives: %w[tesim],
    barcode_derivatives: %w[ssim],
    premade_derivatives: %w[ssim],
    stored_derivatives: %w[ssim]
  }.each_pair do |method, suffixes|
    let(:work_method) { method }
    let(:solr_fields) { suffixes.map { |suffix| "#{method}_#{suffix}" } }

    it_behaves_like 'simple model indexing'
  end
end
