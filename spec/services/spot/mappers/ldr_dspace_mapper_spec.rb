RSpec.describe Spot::Mappers::LdrDspaceMapper do
  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  before do
    mapper.metadata = metadata
  end

  describe '#bibliographic_citation' do
    subject { mapper.bibliographic_citation }

    let(:metadata) { {'identifier.citation' => value} }
    let(:value) { ['Author, FirstName. "Title of Piece"'] }

    it { is_expected.to eq value }

    context 'when no value present' do
      let(:metadata) { {} }

      it { is_expected.to be_empty }
    end
  end

  describe '#contributor' do
    subject { mapper.contributor }

    let(:contributor) { 'Contributor' }
    let(:contributor_other) { 'Other contributor' }

    let(:metadata) do
      {
        'contributor' => [contributor],
        'contributor.other' => [contributor_other]
      }
    end

    it { is_expected.to include contributor }
    it { is_expected.to include contributor_other }
  end

  describe '#date_uploaded' do
    subject { mapper.date_uploaded }

    let(:metadata) { {'date.accessioned' => [value]} }
    let(:value) { '2018-09-17 14:39:00' }

    it { is_expected.not_to be_an Array }
    it { is_expected.to eq value }
  end

  describe '#depositor' do
    subject { mapper.depositor }

    # @todo update this value to a constant / config setting
    let(:default_email) { 'dss@lafayette.edu' }

    context 'when a depositor is provided' do
      let(:email) { 'depositor@lafayette.edu' }
      let(:metadata) { {'description.provenance' => ["Submitted by Person (#{email})"]} }

      it { is_expected.to eq email }
    end

    context 'when none is provided (or found)' do
      let(:metadata) { {} }

      it { is_expected.to eq default_email }
    end

    context 'when a provenance is found but formatted irregularly' do
      let(:metadata) { {'description.provenance' => ['kilroy was here']} }

      it { is_expected.to eq default_email }
    end
  end

  describe '#description' do
    subject { mapper.description }

    let(:description) { 'A description' }
    let(:sponsorship) { 'Stamps dot com folks!' }

    let(:metadata) do
      {
        'description' => [description],
        'description.sponsorship' => [sponsorship]
      }
    end

    it { is_expected.to include description }
    it { is_expected.to include sponsorship }
  end

  describe '#identifier' do
    subject { mapper.identifier }

    context 'with doi values' do
      let(:value) { 'abc/123' }
      let(:metadata) { {'identifier.doi' => [value]} }

      it { is_expected.to eq ["doi:#{value}"] }
    end

    context 'with isbn values' do
      let(:value) { '0-0000-0000-0' }
      let(:metadata) { {'identifier.isbn' => [value]} }

      it { is_expected.to eq ["isbn:#{value}"] }
    end

    context 'with issn values' do
      let(:value) { '0000-0000' }
      let(:metadata) { {'identifier.issn' => [value]} }

      it { is_expected.to eq ["issn:#{value}"] }
    end

    # TODO: this approach has a bad code-smell. go about it differently
    context 'with handles' do
      let(:metadata) do
        {
          'identifier.uri' => ["http://hdl.handle.net/#{value1}"],
          'description.uri' => ["http://hdl.handle.net/#{value2}"]
        }
      end

      let(:value1) { 'abc/123' }
      let(:value2) { 'def/456' }

      it { is_expected.to include "hdl:#{value1}" }
      it { is_expected.to include "hdl:#{value2}" }
    end
  end

  describe '#language' do
    subject { mapper.language }

    let(:value) { ['fr'] }
    let(:metadata) { {'language.iso' => ['fr']} }

    it { is_expected.to eq value }

    context 'when language iso value is en_US' do
      let(:value) { ['en'] }
      let(:metadata) { {'language.iso' => ['en_US']} }

      it { is_expected.to eq value }
    end
  end

  describe '#publisher' do
    subject { mapper.publisher }

    context 'when item is a Book chapter' do
      let(:metadata) {{ 'type' => 'Book chapter', 'publisher' => ['Some journal'] }}

      it { is_expected.to be_empty }
      it { is_expected.not_to eq metadata['publisher']}
    end

    context 'when an item is not a Book chapter' do
      let(:metadata) {{ 'type' => 'Article', 'publisher' => ['Some journal'] }}

      it { is_expected.to eq metadata['publisher'] }
    end
  end

  describe '#source' do
    subject { mapper.source }

    context 'when an item is a Book chapter' do
      let(:metadata) {{ 'type' => 'Book chapter', 'publisher' => ['Some journal'] }}

      it { is_expected.to eq metadata['publisher'] }
    end

    context 'when an item is not a Book chapter' do
      let(:metadata) {{ 'type' => 'Article', 'publisher' => ['Some journal'] }}

      it { is_expected.to be_empty }
      it { is_expected.not_to eq metadata['publisher']}
    end
  end

  describe '#representative_file' do
    subject { mapper.representative_file }

    let(:metadata) { {representative_files: ['some files']} }

    it { is_expected.to eq metadata[:representative_files] }
  end

  # TODO: update when/if we read visibility from a metadata field
  describe '#visibility' do
    subject { mapper.visibility }

    it { is_expected.to eq ::Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
  end
end
