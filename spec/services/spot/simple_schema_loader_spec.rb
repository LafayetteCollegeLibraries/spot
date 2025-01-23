# frozen_string_literal: true
RSpec.describe Spot::SimpleSchemaLoader, valkyrization: true do
  before(:each) do
    # @note can't use described_class in this scope
    class ResourceWithSchemaLoader < Hyrax::Resource
      include Hyrax::Schema(:base_metadata, schema_loader: Spot::SimpleSchemaLoader.new)
    end

    class ResourceWithHyraxSchemaLoader < Hyrax::Resource
      include Hyrax::Schema(:base_metadata)
    end
  end

  after(:each) do
    Object.send(:remove_const, :ResourceWithSchemaLoader)
    Object.send(:remove_const, :ResourceWithHyraxSchemaLoader)
  end

  context 'when using the Hyrax schema loader' do
    let(:resource) { ResourceWithHyraxSchemaLoader.new }

    describe 'URI fields' do
      it 'inits an RDF with a Dry::Types::Undefined value' do
        expect(resource.send(:subject)).to eq [RDF::URI.new(Dry::Types::Undefined)]
        expect(resource.send(:subject).map(&:to_s)).to eq ['Undefined']
      end
    end
  end

  context 'when using our schema loader' do
    let(:schema_loader) { described_class.new }
    let(:resource) { ResourceWithSchemaLoader.new }

    describe 'URI fields' do
      it 'inits no values' do
        expect(resource.send(:subject).map(&:to_s)).to eq []
      end
    end

    it 'wraps single-value fields in an Identity class' do
      expect(schema_loader.attributes_for(schema: :core_metadata))
        .to include(depositor: Spot::SimpleSchemaLoader::AttributeDefinition::Identity.of(Valkyrie::Types::String))
    end
  end
end
