# frozen_string_literal: true
RSpec.shared_examples 'a Spot presenter' do
  subject(:presenter) { described_class.new(solr_doc, ability) }

  let(:factory) { described_class.name.split('::').last.gsub(/Presenter/, '').downcase.to_sym }
  let(:solr_doc) { SolrDocument.new(solr_data) }
  let(:solr_data) { object.to_solr }
  let(:object) { build(factory) }
  let(:ability) { Ability.new(build(:user)) }

  it_behaves_like 'it renders an attribute to HTML'

  describe '#export_formats' do
    subject { presenter.export_formats }

    it { is_expected.to include :csv, :ttl, :nt, :jsonld }
  end

  describe '#public?' do
    subject { presenter.public? }

    context 'when object is public' do
      let(:object) { build(factory, :public) }

      it { is_expected.to be true }
    end

    context 'when object is not public' do
      let(:object) { build(factory, :authenticated) }

      it { is_expected.to be false }
    end
  end

  describe '#location' do
    subject { presenter.location }

    let(:uri) { 'http://sws.geonames.org/5188140/' }
    let(:label) { 'United States, Pennsylvania, Northampton County, Easton' }
    let(:solr_data) do
      {
        'location_ssim' => [uri],
        'location_label_ssim' => [label]
      }
    end

    it { is_expected.to eq [[uri, label]] }
  end

  describe '#manifest_metadata' do
    subject(:manifest_metadata) { presenter.manifest_metadata }

    it 'is an Array of Hashes' do
      expect(manifest_metadata).to be_an Array
      expect(manifest_metadata.all? { |v| v.is_a? Hash }).to be true
      expect(manifest_metadata.all? { |v| v.include?('label') && v.include?('value') })
    end
  end

  describe '#page_title' do
    subject { presenter.page_title }

    it { is_expected.to include presenter.title.first }
    it { is_expected.to include 'Lafayette Digital Repository' }
  end

  describe '#rights_statement_merged' do
    subject { presenter.rights_statement_merged }

    let(:uri) { 'http://creativecommons.org/publicdomain/mark/1.0/' }
    let(:label) { 'Public Domain Mark (PDM)' }

    let(:solr_data) do
      {
        'rights_statement_ssim' => [uri],
        'rights_statement_label_ssim' => [label]
      }
    end

    it { is_expected.to eq [[uri, label]] }
  end
end
