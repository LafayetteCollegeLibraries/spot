# frozen_string_literal: true
RSpec.describe Hyrax::PublicationPresenter do
  subject(:presenter) { described_class.new(solr_doc, ability) }

  let(:solr_doc) { SolrDocument.new(solr_data) }
  let(:solr_data) { object.to_solr }
  let(:object) { build(:publication) }
  let(:ability) { Ability.new(build(:user)) }

  it_behaves_like 'it renders an attribute to HTML'

  describe '#export_formats' do
    subject { presenter.export_formats }

    it { is_expected.to include :csv, :ttl, :nt, :jsonld }
  end

  describe '#public?' do
    subject { presenter.public? }

    context 'when object is public' do
      let(:object) { build(:publication, :public) }

      it { is_expected.to be true }
    end

    context 'when object is not public' do
      let(:object) { build(:publication, :authenticated) }

      it { is_expected.to be false }
    end
  end

  context 'identifier handling' do
    let(:raw_ids) { ['issn:1234-5678', 'abc:123'] }
    let(:object) { build(:publication, identifier: raw_ids) }

    describe '#local_identifier' do
      subject(:ids) { presenter.local_identifier }

      it 'returns only the identifiers that return true to #local?' do
        expect(ids.map(&:to_s)).to eq ['abc:123']
      end

      it 'maps identifiers to Spot::Identifier objects' do
        expect(ids.all? { |id| id.is_a? Spot::Identifier }).to be true
      end
    end

    describe '#standard_identifier' do
      subject(:ids) { presenter.standard_identifier }

      it 'returns only the identifiers that return true to #standard?' do
        expect(ids.map(&:to_s)).to eq ['issn:1234-5678']
      end

      it 'maps identifiers to Spot::Identifier objects' do
        expect(ids.all? { |id| id.is_a? Spot::Identifier }).to be true
      end
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
