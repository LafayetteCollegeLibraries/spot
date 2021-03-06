# frozen_string_literal: true
RSpec.describe Spot::Mappers::LdrDspaceMapper do
  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  before do
    mapper.metadata = metadata
  end

  describe '#abstract' do
    subject { mapper.abstract }

    let(:metadata) { { 'description.abstract' => value } }
    let(:value) { ['a short description'] }

    it { is_expected.to eq value }

    context 'when a value previously included a semicolon' do
      let(:original_value) { ['a short description; you see?'] }
      let(:value) { original_value.first.split(';') }

      it { is_expected.to eq original_value }
    end
  end

  describe '#bibliographic_citation' do
    subject { mapper.bibliographic_citation }

    let(:metadata) { { 'identifier.citation' => value } }
    let(:value) { ['Author, FirstName. "Title of Piece"'] }

    it { is_expected.to eq value }

    context 'when no value present' do
      let(:metadata) { {} }

      it { is_expected.to be_empty }
    end

    context 'when a value previously included a semicolon' do
      let(:original_value) { ['one;two;three'] }
      let(:value) { original_value.first.split(';') }

      it { is_expected.to eq original_value }
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

  describe '#date_available' do
    subject { mapper.date_available }

    let(:metadata) { { 'date.available' => [date] } }
    let(:date) { '2019-01-29T13:31:00Z' }

    it { is_expected.to eq [date] }
  end

  describe '#date_issued' do
    subject { mapper.date_issued }

    let(:metadata) { { 'date.issued' => [date] } }

    context 'when YYYY' do
      let(:date) { '2019' }

      it { is_expected.to eq [date] }
    end

    context 'when YYYY-MM' do
      let(:date) { '2019-01' }

      it { is_expected.to eq [date] }
    end

    context 'when YYYY-MM-DD' do
      let(:date) { '2019-01-29' }

      it { is_expected.to eq [date] }
    end

    context 'when YYYY-MM-DDTHH:MM:SSZ' do
      let(:date) { '2019-01-29T13:28:00Z' }

      it { is_expected.to eq ['2019-01-29'] }
    end
  end

  describe '#date_uploaded' do
    subject { mapper.date_uploaded }

    let(:metadata) { { 'date.accessioned' => [value] } }
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
      let(:metadata) { { 'description.provenance' => ["Submitted by Person (#{email})"] } }

      it { is_expected.to eq email }
    end

    context 'when none is provided (or found)' do
      let(:metadata) { {} }

      it { is_expected.to eq default_email }
    end

    context 'when a provenance is found but formatted irregularly' do
      let(:metadata) { { 'description.provenance' => ['kilroy was here'] } }

      it { is_expected.to eq default_email }
    end
  end

  describe '#description' do
    subject { mapper.description }

    let(:description) { ['A description'] }
    let(:sponsorship) { ['Stamps dot com folks!'] }

    let(:metadata) do
      {
        'description' => description,
        'description.sponsorship' => sponsorship
      }
    end

    it { is_expected.to include description.first }
    it { is_expected.to include sponsorship.first }

    context 'when original values included semicolons' do
      let(:original_description) { 'first;second' }
      let(:description) { original_description.split(';') }
      let(:original_sponsorship) { 'first;second' }
      let(:sponsorship) { original_sponsorship.split(';') }

      it { is_expected.to include original_description }
      it { is_expected.to include original_sponsorship }
    end
  end

  describe '#identifier' do
    subject { mapper.identifier }

    context 'with doi values' do
      let(:value) { 'abc/123' }
      let(:metadata) { { 'identifier.doi' => [value] } }

      it { is_expected.to eq ["doi:#{value}"] }
    end

    context 'with isbn values' do
      let(:value) { '0-0000-0000-0' }
      let(:metadata) { { 'identifier.isbn' => [value] } }

      it { is_expected.to eq ["isbn:#{value}"] }
    end

    context 'with issn values' do
      let(:value) { '0000-0000' }
      let(:metadata) { { 'identifier.issn' => [value] } }

      it { is_expected.to eq ["issn:#{value}"] }
    end

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

  describe '#language_attributes' do
    subject { mapper.language }

    let(:metadata) { { 'language.iso' => %w[en fr] } }

    it { is_expected.to eq %w[en fr] }

    context 'when metadata contains en_US' do
      let(:metadata) { { 'language.iso' => %w[en_US fr] } }

      it { is_expected.to eq %w[en fr] }
    end
  end

  describe '#publisher' do
    subject { mapper.publisher }

    let(:metadata) { { 'type' => [type], 'publisher' => ['Some journal'] } }

    context 'when an item is a Book chapter' do
      let(:type) { 'Book chapter' }

      it { is_expected.to be_empty }
    end

    context 'when an item is a Part of Book' do
      let(:type) { 'Part of Book' }

      it { is_expected.to be_empty }
    end

    context 'when an item is not a Book chapter' do
      let(:type) { 'Article' }

      it { is_expected.to eq metadata['publisher'] }
    end
  end

  describe '#source' do
    subject { mapper.source }

    let(:metadata) { { 'type' => [type], 'publisher' => ['Some journal'] } }

    context 'when an item is a Book chapter' do
      let(:type) { 'Book chapter' }

      it { is_expected.to eq metadata['publisher'] }
    end

    context 'when an item is Part of Book' do
      let(:type) { 'Part of Book' }

      it { is_expected.to eq metadata['publisher'] }
    end

    context 'when an item is not a Book chapter' do
      let(:type) { 'Article' }

      it { is_expected.to be_empty }
    end
  end

  describe '#representative_file' do
    subject { mapper.representative_file }

    let(:metadata) { { 'representative_files' => ['some files'] } }

    it { is_expected.to eq metadata['representative_files'] }
  end

  describe '#rights_statement' do
    subject { mapper.rights_statement }

    let(:field) { 'dc:rights' }

    it_behaves_like 'a mapped field'
  end

  describe '#title' do
    subject { mapper.title }

    let(:metadata) { { 'title' => value } }
    let(:value) { ['title value'] }

    it { is_expected.to eq value }

    context 'when a semicolon was originally present' do
      let(:original_value) { ['first;second'] }
      let(:expected_value) { original_value.map { |v| RDF::Literal.new(v) } }
      let(:value) { original_value.first.split(';') }

      it { is_expected.to eq expected_value }
    end

    context 'when a value has a language tag attached' do
      let(:value) { ['Une bonne chose_<fr>'] }
      let(:expected_value) { [RDF::Literal.new('Une bonne chose', language: :fr)] }

      it { is_expected.to eq expected_value }
    end
  end

  # TODO: update when/if we read visibility from a metadata field
  describe '#visibility' do
    subject { mapper.visibility }

    it { is_expected.to eq ::Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
  end
end
