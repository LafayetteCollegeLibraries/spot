# frozen_string_literal: true
RSpec.describe Spot::Mappers::AlsaceImagesMapper do
  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  before { mapper.metadata = metadata }

  it_behaves_like 'it has language-tagged titles'

  describe '#inscription' do
    subject { mapper.inscription }

    let(:metadata) do
      {
        'description.inscription.french' => ['Partez bien bien vite vers ce midi'],
        'description.inscription.german' => ['Lebende bad.'],
        'description.text.french' => ['Les vandales pleure pas!'],
        'description.text.german' => ['Volkstracht aus Allmannweier']
      }
    end

    let(:expected_results) do
      [
        RDF::Literal('Partez bien bien vite vers ce midi', language: :fr),
        RDF::Literal('Lebende bad.', language: :de),
        RDF::Literal('Les vandales pleure pas!', language: :fr),
        RDF::Literal('Volkstracht aus Allmannweier', language: :de)
      ]
    end

    it { is_expected.to include(*expected_results) }
  end

  describe '#resource_type' do
    subject { mapper.resource_type }

    it { is_expected.to eq ['Image'] }
  end
end
