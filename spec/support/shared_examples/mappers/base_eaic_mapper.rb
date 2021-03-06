# frozen_string_literal: true
#
# Going with an options object so that we can use keyword fields to understand
# what exactly is being passed.
#
# @example passing a skip_fields parameter
#   it_behaves_like 'a base EAIC mapper', skip_fields: [:identifier]
#
RSpec.shared_examples 'a base EAIC mapper' do |options|
  options ||= {}

  fields = described_class.new.fields
  skip_fields = options.fetch(:skip_fields, [])

  it_behaves_like 'it has language-tagged titles', skip_fields: skip_fields
  it_behaves_like 'it maps original create date'
  it_behaves_like 'it maps image creation note'

  describe '#representative_file' do
    subject { mapper.representative_file }

    let(:metadata) { { 'representative_files' => files } }

    context 'with backs designated with "b"' do
      let(:files) do
        ['lc-spcol-pacwar-postcards-0009b.tif', 'lc-spcol-pacwar-postcards-0009.tif']
      end

      it { is_expected.to eq ['lc-spcol-pacwar-postcards-0009.tif', 'lc-spcol-pacwar-postcards-0009b.tif'] }
    end

    context 'with backs designated with "-back"' do
      let(:files) do
        ['lc-spcol-woodsworth-images-0043-back.tif', 'lc-spcol-woodsworth-images-0043.tif']
      end

      it { is_expected.to eq ['lc-spcol-woodsworth-images-0043.tif', 'lc-spcol-woodsworth-images-0043-back.tif'] }
    end
  end

  if fields.include?(:date) && !skip_fields.include?(:date)
    describe '#date' do
      subject { mapper.date }

      let(:metadata) { { 'date.artifact.lower' => date_lower, 'date.artifact.upper' => date_upper } }
      let(:date_lower) { ['1930'] }
      let(:date_upper) { ['1952-06'] }

      it { is_expected.to eq ['1930/1952-06'] }

      context 'when no lower date present' do
        let(:date_lower) { [] }

        it { is_expected.to eq ['1952-06'] }
      end

      context 'when no upper date present' do
        let(:date_upper) { [] }

        it { is_expected.to eq ['1930'] }
      end

      context 'when lower + upper dates match' do
        let(:date_lower) { ['1930'] }
        let(:date_upper) { ['1930'] }

        it { is_expected.to eq ['1930'] }
      end

      context 'when lower + upper dates are out of order' do
        let(:date_lower) { ['1986-02-11'] }
        let(:date_upper) { ['1986-02'] }

        it { is_expected.to eq ['1986-02/1986-02-11'] }
      end
    end
  end

  if fields.include?(:date_associated) && !skip_fields.include?(:date_associated)
    describe '#date_associated' do
      subject { mapper.date_associated }

      let(:metadata) do
        { 'date.image.lower' => ['1921-01'], 'date.image.upper' => ['1932-02-11'] }
      end

      it { is_expected.to eq ['1921-01/1932-02-11'] }

      context 'when lower + upper dates match' do
        let(:metadata) do
          { 'date.image.lower' => ['1921-01'], 'date.image.upper' => ['1921-01'] }
        end

        it { is_expected.to eq ['1921-01'] }
      end
    end
  end

  if fields.include?(:description) && !skip_fields.include?(:description)
    describe '#description' do
      subject { mapper.description }

      let(:metadata) { { 'description.critical' => ['It is an Image. A nice one.'] } }

      it { is_expected.to include RDF::Literal('It is an Image. A nice one.', language: :en) }
    end
  end

  if fields.include?(:identifier) && !skip_fields.include?(:identifier)
    it_behaves_like 'it maps Islandora URLs to identifiers'

    describe '#identifier' do
      subject { mapper.identifier }

      let(:title_field) { 'title.english' }

      context 'when a title has an ID in it' do
        let(:metadata) { { title_field => ['[ww0001] [A description of the object]'] } }

        it { is_expected.to include Spot::Identifier.new('eaic', 'ww0001').to_s }
      end
    end
  end

  if fields.include?(:location) && !skip_fields.include?(:location)
    describe '#location' do
      subject { mapper.location }

      let(:metadata) do
        {
          'coverage.location' => ['https://www.geonames.org/1668341', 'https://www.geonames.org/6728591'],
          'coverage.location.country' => ['Netia']
        }
      end

      let(:expected_values) do
        [RDF::URI('https://www.geonames.org/1668341'), RDF::URI('https://www.geonames.org/6728591'), 'Netia']
      end

      it { is_expected.to eq expected_values }
    end
  end

  if fields.include?(:rights_statement) && !skip_fields.include?(:rights_statement)
    describe '#rights_statement' do
      subject { mapper.rights_statement }

      let(:uri) { 'http://rightsstatements.org/vocab/InC-EDU/1.0/' }
      let(:metadata) { { 'rights.statement' => [uri] } }

      it { is_expected.to eq [RDF::URI(uri)] }

      context 'when the field used is rights.digital' do
        let(:metadata) { { 'rights.digital' => [uri] } }

        it { is_expected.to eq [RDF::URI(uri)] }
      end
    end
  end

  if fields.include?(:subject) && !skip_fields.include?(:subject)
    describe '#subject' do
      subject { mapper.subject }

      let(:metadata) { { 'subject' => ['http://id.worldcat.org/fast/1142133'] } }

      it { is_expected.to eq [RDF::URI('http://id.worldcat.org/fast/1142133')] }
    end
  end
end
