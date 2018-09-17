RSpec.describe Spot::Mappers::NewspaperMapper do
  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  before { mapper.metadata = metadata }

  describe '#based_near' do
    subject(:based_near) { mapper.based_near }

    context 'when location is Easton' do
      let(:metadata) do
        {
          'dc:coverage' => ['United States, Pennsylvania, Northampton County, Easton']
        }
      end

      it 'is an RDF::URI' do
        expect(based_near.first).to be_an ::RDF::URI
      end
    end

    context 'when it is any place else' do
      let(:metadata) do
        {
          'dc:coverage' => ['Anywhere, USA']
        }
      end

      it 'is the supplied value' do
        expect(based_near.first).to be_a String
      end
    end
  end

  describe '#date_issued' do
    subject { mapper.date_issued }

    let(:value) do
      %w[
        2018-09-01
        2018-09-02
      ]
    end

    let(:metadata) do
      {
        'dc:date' => %w[
          2018-09-01T00:00:00Z
          2018-09-02T00:00:00Z
        ]
      }
    end

    it { is_expected.to eq value }
  end

  describe '#description' do
    subject { mapper.description }

    let(:field) { 'dc:description' }

    it_behaves_like 'a mapped field'
  end

  describe '#identifier' do
    subject { mapper.identifier }

    let(:field) { 'dc:identifier' }

    it_behaves_like 'a mapped field'
  end

  describe '#keyword' do
    subject { mapper.keyword }

    let(:field) { 'dc:subject' }

    it_behaves_like 'a mapped field'
  end

  describe '#physical_medium' do
    subject { mapper.physical_medium }

    let(:field) { 'dc:source' }

    it_behaves_like 'a mapped field'
  end

  describe '#publisher' do
    subject { mapper.publisher }

    let(:field) { 'dc:publisher' }

    it_behaves_like 'a mapped field'
  end

  describe '#resource_type' do
    subject { mapper.resource_type }

    let(:field) { 'dc:type' }

    it_behaves_like 'a mapped field'
  end

  describe '#rights_statement' do
    subject(:rights_statement) { mapper.rights_statement }

    let(:metadata) { {'dc:rights' => [rights]} }

    context 'when in the Public domain' do
      let(:rights) { 'Public domain' }

      it 'is an RDF::URI' do
        expect(rights_statement.first).to be_an ::RDF::URI
      end
    end

    context 'when not in the Public domain' do
      let(:rights) { 'No way you can use this' }

      it 'keeps the existing value' do
        expect(rights_statement.first).to eq rights
      end
    end
  end

  describe '#title' do
    subject { mapper.title }

    let(:field) { 'dc:title' }

    it_behaves_like 'a mapped field'
  end
end
