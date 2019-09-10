# frozen_string_literal: true
RSpec.describe Hyrax::PublicationPresenter do
  subject(:presenter) { described_class.new(solr_doc, ability) }

  let(:solr_doc) { SolrDocument.new(solr_data) }
  let(:solr_data) { object.to_solr }
  let(:object) { build(:publication) }
  let(:ability) { Ability.new(build(:user)) }

  it_behaves_like 'a Spot presenter'

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

  describe '#subject' do
    subject { presenter.subject }

    let(:uri) { 'http://id.worldcat.org/fast/2004076' }
    let(:label) { 'Little free libraries' }
    let(:solr_data) do
      {
        'subject_ssim' => [uri],
        'subject_label_ssim' => [label]
      }
    end

    it { is_expected.to eq [[uri, label]] }
  end
end
