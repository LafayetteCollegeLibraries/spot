RSpec.describe Spot::Mappers::NewspaperMapper do
  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  before { mapper.metadata = metadata }

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

  describe '#keyword' do
    subject { mapper.keyword }

    let(:field) { 'dc:subject' }

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

  describe '#title' do
    subject { mapper.title }

    let(:field) { 'dc:title' }

    it_behaves_like 'a mapped field'
  end
end
