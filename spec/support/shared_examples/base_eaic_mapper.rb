# frozen_string_literal: true
RSpec.shared_examples 'a base EAIC mapper' do
  it_behaves_like 'it has language-tagged titles'

  fields = described_class.new.fields

  if fields.include?(:date)
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
    end
  end

  if fields.include?(:description)
    describe '#description' do
      subject { mapper.description }

      let(:metadata) { { 'description.critical' => ['It is an Image. A nice one.'] } }

      it { is_expected.to eq [RDF::Literal('It is an Image. A nice one.', language: :en)] }
    end
  end

  if fields.include?(:identifier)
    describe '#identifier' do
      subject { mapper.identifier }

      let(:title_field) { 'title.english' }

      context 'when a title has an ID in it' do
        let(:metadata) { { title_field => ['[ww0001] [A description of the object]'] } }

        it { is_expected.to include Spot::Identifier.new('eaic', 'ww0001').to_s }
      end
    end
  end

  if fields.include?(:location)
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

  if fields.include?(:rights_statement)
    describe '#rights_statement' do
      subject { mapper.rights_statement }

      let(:metadata) { { 'rights.statement' => ['http://rightsstatements.org/vocab/InC-EDU/1.0/'] } }

      it { is_expected.to eq [RDF::URI('http://rightsstatements.org/vocab/InC-EDU/1.0/')] }
    end
  end

  if fields.include?(:subject)
    describe '#subject' do
      subject { mapper.subject }

      let(:metadata) { { 'subject' => ['http://id.worldcat.org/fast/1142133'] } }

      it { is_expected.to eq [RDF::URI('http://id.worldcat.org/fast/1142133')] }
    end
  end
end
