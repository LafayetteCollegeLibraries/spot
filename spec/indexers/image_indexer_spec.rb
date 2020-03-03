# frozen_string_literal: true
RSpec.describe ImageIndexer do
  include_context 'indexing'

  it_behaves_like 'a Spot indexer'

  {
    title: %w[tesim],
    subtitle: %w[tesim],
    title_alternative: %w[tesim],
    publisher: %w[tesim sim],
    repository_location: %w[ssim],
    source: %w[ssim],
    resource_type: %w[ssim],
    physical_medium: %w[tesim sim],
    original_item_extent: %w[tesim],
    description: %w[tesim],
    inscription: %w[tesim],
    date_scope_note: %w[tesim],
    creator: %w[tesim sim],
    contributor: %w[tesim sim],
    related_resource: %w[tesim sim],
    subject_ocm: %w[ssim]
  }.each_pair do |method, suffixes|
    let(:work_method) { method }
    let(:solr_fields) { suffixes.map { |suffix| "#{method}_#{suffix}" } }

    it_behaves_like 'simple model indexing'
  end

  describe 'sortable date' do
    let(:work) { build(:image, date: ['2019-12?']) }

    it 'parses a sortable date' do
      expect(solr_doc['date_sort_dtsi']).to eq '2019-12-01T00:00:00Z'
    end
  end

  describe 'years_encompassed' do
    let(:work) { build(:image, date: ['1986/1988'], date_associated: ['1959-08-13', '1958-01-22', '1986-02-11']) }

    it 'generates an array of encompassed years' do
      expect(solr_doc['years_encompassed_iim']).to eq [1958, 1959, 1986, 1987, 1988]
    end
  end
end
