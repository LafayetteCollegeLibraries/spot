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

  describe '#identifier' do
    subject(:ids) { presenter.identifier }

    let(:object) { build(:publication, identifier: ['abc:123', 'hdl:111/222']) }

    it 'maps identifiers to Spot::Identifier objects' do
      expect(ids.all? { |id| id.is_a? Spot::Identifier }).to be true
    end
  end

  describe '#place' do
    subject { presenter.place }

    let(:uri) { 'http://sws.geonames.org/5188140/' }
    let(:label) { 'United States, Pennsylvania, Northampton County, Easton' }
    let(:solr_data) do
      {
        'place_ssim' => [uri],
        'place_label_ssim' => [label]
      }
    end

    it { is_expected.to eq [[uri, label]] }
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
