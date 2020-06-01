# frozen_string_literal: true
RSpec.shared_examples 'it has language-tagged titles' do |options|
  options ||= {}
  skip_fields = options.fetch(:skip_fields, [])

  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  before do
    mapper.metadata = metadata
  end

  if described_class.new.fields.include?(:title) && !skip_fields.include?(:title)
    describe '#title' do
      subject { mapper.title }

      let(:primary_title_key) { described_class.primary_title_map.keys.first }
      let(:metadata) { { primary_title_key => 'The Beyond' } }

      it { is_expected.to eq [RDF::Literal('The Beyond', language: :en)] }
    end
  end

  if described_class.new.fields.include?(:title_alternative) && !skip_fields.include?(:title_alternative)
    describe '#title_alternative' do
      subject { mapper.title_alternative }

      let(:spec_title_alternative_map) do
        { 'title.french' => :fr, 'title.german' => :de }
      end

      let(:metadata) do
        { 'title.french' => ["L'au-delà"], 'title.german' => ['Die Geisterstadt der Zombies'] }
      end

      # rubocop:disable RSpec/InstanceVariable
      before do
        @previous_title_alternative_map = described_class.title_alternative_map
        described_class.title_alternative_map = spec_title_alternative_map
      end

      after do
        described_class.title_alternative_map = @previous_title_alternative_map
      end
      # rubocop:enable RSpec/InstanceVariable

      it do
        is_expected.to include(RDF::Literal("L'au-delà", language: :fr),
                               RDF::Literal('Die Geisterstadt der Zombies', language: :de))
      end
    end
  end
end
