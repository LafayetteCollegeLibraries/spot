# frozen_string_literal: true
RSpec.describe Spot::BasePresenter do
  subject(:presenter) { described_class.new(solr_doc, ability) }

  let(:solr_doc) { SolrDocument.new(solr_data) }
  let(:solr_data) { object.to_solr }
  let(:object) { build(:publication) }
  let(:ability) { Ability.new(build(:user)) }

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

  describe '#mapped_identifiers' do
    subject(:ids) { presenter.mapped_identifiers }

    let(:object) { build(:publication, identifier: ['abc:123', 'hdl:111/222']) }

    it 'maps identifiers to Spot::Identifier objects' do
      expect(ids.all? { |id| id.is_a? Spot::Identifier }).to be true
    end
  end

  describe '#place' do
    subject { presenter.place }

    let(:solr_data) do
      {
        'place_ssim' => ['http://sws.geonames.org/5188140/']
      }
    end

    it { is_expected.to eq solr_doc['place_ssim'] }
  end

  describe '#place_merged' do
    subject { presenter.place_merged.first }

    let(:uri) { 'http://sws.geonames.org/5188140/' }
    let(:label) { 'United States, Pennsylvania, Northampton County, Easton' }
    let(:solr_data) do
      {
        'place_ssim' => [uri],
        'place_label_ssim' => [label]
      }
    end

    it { is_expected.to eq [uri, label] }
  end

  describe '#date_modified' do
    subject { presenter.date_modified }

    let(:solr_data) { { 'date_modified_dtsi' => '2018-11-27T18:44:05Z' } }

    it { is_expected.to eq solr_doc['date_modified_dtsi'] }
  end

  describe '#date_uploaded' do
    subject { presenter.date_uploaded }

    let(:solr_data) { { 'date_uploaded_dtsi' => '2018-11-27T18:44:05Z' } }

    it { is_expected.to eq solr_doc['date_uploaded_dtsi'] }
  end

  describe '#license' do
    subject { presenter.license }

    let(:solr_data) { { 'license_ssim' => 'Public Domain' } }

    it { is_expected.to eq solr_doc['license_ssim'] }
  end

  # these are the straightforward checks
  {
    'abstract' => 'tesim',
    'academic_department' => 'tesim',
    'bibliographic_citation' => 'tesim',
    'contributor' => 'tesim',
    'creator' => 'tesim',
    'date_available' => 'ssim',
    'date_issued' => 'ssim',
    'depositor' => 'tesim',
    'description' => 'tesim',
    'division' => 'ssim',
    'editor' => 'tesim',
    'identifier' => 'ssim',
    'keyword' => 'tesim',
    'language_label' => 'ssim',
    'organization' => 'ssim',
    'resource_type' => 'ssim',
    'source' => 'tesim',
    'subject' => 'tesim',
    'subtitle' => 'tesim',
    'title_alternative' => 'tesim'
  }.each_pair do |method, suffix|
    describe "##{method}" do
      subject { presenter.send(method.to_sym) }

      it { is_expected.to eq solr_doc["#{method}_#{suffix}"] }
    end
  end
end
