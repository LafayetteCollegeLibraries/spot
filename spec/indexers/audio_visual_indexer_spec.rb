# frozen_string_literal: true
RSpec.describe AudioVisualIndexer do
  include_context 'indexing'

  it_behaves_like 'a Spot indexer'
  it_behaves_like 'it indexes a sortable date'

  {
    title: %w[tesim],
    premade_derivatives: %w[ssim],
    stored_derivatives: %w[ssim]
  }.each_pair do |method, suffixes|
    let(:work_method) { method }
    let(:solr_fields) { suffixes.map { |suffix| "#{method}_#{suffix}" } }

    it_behaves_like 'simple model indexing'
  end
end
