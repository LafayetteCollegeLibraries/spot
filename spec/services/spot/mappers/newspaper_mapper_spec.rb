RSpec.describe Spot::Mappers::NewspaperMapper do
  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  before { mapper.metadata = metadata }

  shared_examples 'a mapped field' do
    subject { mapper.send(method) }

    let(:value) { ['some value'] }
    let(:metadata) { {field => value} }

    it { is_expected.to eq value }
  end

  describe '#date_issued' do
    subject { mapper.date_issued }

    let(:value) { %w[2018-09-01 2018-09-02] }
    let(:metadata) do
      { 'dc:date' => %w[2018-09-01T00:00:00Z 2018-09-02T00:00:00Z] }
    end

    it { is_expected.to eq value }
  end

  describe '#description' do
    let(:method) { :description }
    let(:field) { 'dc:description' }

    it_behaves_like 'a mapped field'
  end

  describe '#keyword' do
    let(:method) { :keyword }
    let(:field) { 'dc:subject' }

    it_behaves_like 'a mapped field'
  end

  describe '#publisher' do
    let(:method) { :publisher }
    let(:field) { 'dc:publisher' }

    it_behaves_like 'a mapped field'
  end

  describe '#resource_type' do
    let(:method) { :resource_type }
    let(:field) { 'dc:type' }

    it_behaves_like 'a mapped field'
  end

  describe '#title' do
    let(:method) { :title }
    let(:field) { 'dc:title' }

    it_behaves_like 'a mapped field'
  end
end
