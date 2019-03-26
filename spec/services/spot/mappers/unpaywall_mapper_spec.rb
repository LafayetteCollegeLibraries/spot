# frozen_string_literal: true
RSpec.describe Spot::Mappers::UnpaywallMapper do
  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  before do
    mapper.metadata = metadata
  end

  describe 'fields_map properties' do
    describe '#date_issued' do
      subject { mapper.date_issued }

      let(:metadata) { { 'published_date' => '2019-03-20' } }

      it { is_expected.to eq ['2019-03-20'] }
    end

    describe '#publisher' do
      subject { mapper.publisher }

      let(:metadata) { { 'publisher' => 'Silver Star Film Company' } }

      it { is_expected.to eq ['Silver Star Film Company'] }
    end

    describe '#source' do
      subject { mapper.source }

      let(:metadata) { { 'journal_name' => 'Nature' } }

      it { is_expected.to eq ['Nature'] }
    end

    describe '#title' do
      subject { mapper.title }

      let(:metadata) { { 'title' => 'E-mo-tion' } }

      it { is_expected.to eq ['E-mo-tion'] }
    end
  end

  describe '#contributor' do
    subject { mapper.contributor }

    let(:metadata) do
      {
        'z_authors' => [
          { 'family' => 'Wishman', 'given' => 'Doris' },
          { 'family' => 'Friedman', 'given' => 'David' }
        ]
      }
    end

    it { is_expected.to contain_exactly 'Wishman, Doris', 'Friedman, David' }

    context 'when no authors present' do
      let(:metadata) { { 'z_authors' => nil } }

      it { is_expected.to eq [] }
    end
  end

  describe '#identifier' do
    subject { mapper.identifier }

    let(:doi) { '00.000/abc123/def456' }
    let(:base_metadata) { { 'doi' => doi } }
    let(:metadata) { base_metadata }

    it { is_expected.to contain_exactly "doi:#{doi}" }

    context 'when journal issn is provided' do
      let(:metadata) { base_metadata.merge('journal_issns' => '1234-5678') }

      it { is_expected.to contain_exactly "doi:#{doi}", 'issn:1234-5678' }
    end
  end

  describe '#license' do
    subject { mapper.license }

    context 'when best_oa_location is available' do
      let(:metadata) do
        { 'best_oa_location' => { 'license' => 'implied-oa' } }
      end

      it { is_expected.to eq ['implied-oa'] }
    end

    context 'when best_oa_location not available' do
      it { is_expected.to be_empty }
    end
  end

  describe '#representative_file' do
    subject { mapper.representative_file }

    context 'when best_oa_location is available' do
      let(:metadata) do
        { 'best_oa_location' => { 'url_for_pdf' => 'http://example.org/a-very-good.pdf' } }
      end

      it { is_expected.to eq ['http://example.org/a-very-good.pdf'] }
    end

    context 'when best_oa_location not available' do
      it { is_expected.to be_empty }
    end
  end
end
