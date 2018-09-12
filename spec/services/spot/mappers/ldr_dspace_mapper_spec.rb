require 'csv'
RSpec.describe Spot::Mappers::LdrDspaceMapper do
  let(:mapper) { described_class.new }
  let(:csv_path) { ::Rails.root.join('spec', 'fixtures', 'ldr-bag-metadata.csv') }
  let(:metadata) { CsvSupport.parse_bag_metadata_to_hash(csv_path) }

  before do
    mapper.metadata = metadata
  end

  describe '#bibliographic_citation' do
    subject { mapper.bibliographic_citation }

    it { is_expected.to eq metadata['identifier.citation'] }

    context 'when no value present' do
      let(:metadata) { {} }

      it { is_expected.to be_empty }
    end
  end

  describe '#contributor' do
    subject { mapper.contributor }

    it { is_expected.to include *metadata['contributor'] }
    it { is_expected.to include *metadata['contributor.other'] }
  end

  describe '#date_uploaded' do
    subject { mapper.date_uploaded }

    it { is_expected.to include *metadata['date.accessioned'] }
  end

  describe '#depositor' do
    subject { mapper.depositor }

    context 'when a depositor is provided' do
      let(:email) { 'depositor@lafayette.edu' }
      let(:metadata) { {'description.provenance' => ["Submitted by Person (#{email})"]} }

      it { is_expected.to eq email }
    end

    context 'when none is provided (or found)' do
      let(:metadata) { {} }

      it { is_expected.to eq 'dss@lafayette.edu' }
    end
  end

  describe '#description' do
    subject { mapper.description }

    it { is_expected.to include *metadata['description'] }
    it { is_expected.to include *metadata['description.sponsorship'] }
  end

  describe '#identifier' do
    subject { mapper.identifier }

    let(:values) { metadata["identifier.#{prefix}"].map { |val| "#{prefix}:#{val}" } }

    context 'with doi values' do
      let(:prefix) { 'doi' }

      it { is_expected.to include *values }
    end

    context 'with isbn values' do
      let(:prefix) { 'isbn' }

      it { is_expected.to include *values }
    end

    context 'with issn values' do
      let(:prefix) { is_expected.to include *values }
    end

    # TODO: this approach has a bad code-smell. go about it differently
    context 'with handles' do
      let(:values) { mapper.send(:uris_with_handles_mapped) }

      it { is_expected.to include *values }
    end
  end

  describe '#language' do
    subject { mapper.language }
    let(:metadata) { {'language.iso' => ['fr']} }

    it { is_expected.to eq metadata['language.iso'] }

    context 'when language iso value is en_US' do
      let(:metadata) { {'language.iso' => ['en_US']} }

      it { is_expected.to eq ['en'] }
      it { is_expected.not_to include *metadata['language'] }
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
