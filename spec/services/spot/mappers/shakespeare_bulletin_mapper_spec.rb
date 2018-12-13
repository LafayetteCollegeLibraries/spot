# frozen_string_literal: true
RSpec.describe Spot::Mappers::ShakespeareBulletinMapper do
  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  # used for both #creator and #editor
  let(:name_metadata) do
    {
      'name1_role' => ['editor'],
      'name1_displayForm' => ['Person 1'],
      'name2_role' => ['author'],
      'name2_displayForm' => ['Person 2'],
      'name3_role' => ['co-editor'],
      'name3_displayForm' => ['Person 3'],
      'name4_role' => ['author'],
      'name4_displayForm' => ['Person 4']
    }
  end

  before do
    mapper.metadata = metadata
  end

  describe '#creator' do
    subject { mapper.creator }

    let(:value) { ['Person 2', 'Person 4'] }
    let(:metadata) { name_metadata }

    it { is_expected.to eq value }
  end

  describe '#date_issued' do
    subject { mapper.date_issued }

    let(:value) { %w[1976-01-01 2003-11-01] }
    let(:metadata) do
      { 'originInfo_dateIssued_ISO8601' => %w[1/1/76 11/1/03] }
    end

    it { is_expected.to eq value }
  end

  describe '#editor' do
    subject { mapper.editor }

    let(:value) { ['Person 1', 'Person 3'] }
    let(:metadata) { name_metadata }

    it { is_expected.to eq value }
  end

  describe '#identifier' do
    subject { mapper.identifier }

    let(:value) { ['issn:1234-5678'] }
    let(:metadata) { { 'relatedItem_identifier_typeISSN' => ['1234-5678'] } }

    it { is_expected.to eq value }
  end

  describe '#publisher' do
    subject { mapper.publisher }

    let(:field) { 'originInfo_Publisher' }

    it_behaves_like 'a mapped field'
  end

  describe '#source' do
    subject { mapper.source }

    let(:field) { 'relatedItem_typeHost_titleInfo_title' }

    it_behaves_like 'a mapped field'
  end

  describe '#subtitle' do
    subject { mapper.subtitle }

    let(:metadata) do
      {
        'titleInfo_subTitle' => ['2 be or not 2 be']
      }
    end

    let(:value) { [RDF::Literal('2 be or not 2 be', language: :en)] }

    it { is_expected.to eq value }
  end

  describe '#title' do
    subject { mapper.title }

    let(:title) do
      [
        RDF::Literal('Shakespeare Bulletin (May, 1983) [vol. 1, no. 11]', language: :en)
      ]
    end

    let(:metadata) do
      {
        'titleInfo_Title' => ['Shakespeare Bulletin'],
        'relatedItem_part1_date_qualifierApproximate' => ['May, 1983'],
        'relatedItem_part1_detail1_typeVolume_caption' => ['vol.'],
        'relatedItem_part1_detail1_typeVolume_number' => ['1'],
        'relatedItem_part1_detail1_typeIssue_caption' => ['no.'],
        'relatedItem_part1_detail1_typeIssue_number' => ['11']
      }
    end

    it { is_expected.to eq title }

    context 'when just a title exists' do
      let(:title) { [RDF::Literal('Shakespeare Bulletin', language: :en)] }
      let(:metadata) { { 'titleInfo_Title' => ['Shakespeare Bulletin'] } }

      it { is_expected.to eq title }
    end
  end

  describe '#based_near_attributes' do
    subject { mapper.based_near_attributes }

    let(:metadata) do
      {
        'originInfo_place_placeTerm' => [
          'Burlington, VT',
          'Norwood, NJ',
          'Easton, PA'
        ]
      }
    end

    let(:expected_hash) do
      {
        '0' => { 'id' => 'http://sws.geonames.org/5234372/' },
        '1' => { 'id' => 'http://sws.geonames.org/5101978/' },
        '2' => { 'id' => 'http://sws.geonames.org/5188140/' }
      }
    end

    it { is_expected.to eq expected_hash }

    context 'when a value is not expected' do
      let(:metadata) do
        { 'originInfo_place_placeTerm' => ['Nowheresville, USA'] }
      end

      it_behaves_like 'it logs a warning'

      it { is_expected.to be_empty }
    end
  end
end
