RSpec.describe Spot::Importers::Bag::Parser do
  subject(:parser) { described_class.new(file: fixture_path, mapper: mapper) }
  let(:mapper) { double('mapper') }
  let(:bag_name) { 'ldr-bag' }
  let(:fixture_path) { ::Rails.root.join('spec', 'fixtures', bag_name) }
  let(:not_a_bag_path) { ::Rails.root.join('spec', 'fixtures', "#{bag_name}.zip") }

  before do
    # fake it 'til ya make it
    allow(mapper).to receive(:'metadata=')
  end

  describe '#validate' do
    subject { parser.validate }

    it { is_expected.to be true }

    context 'when the file is not a valid bag' do
      let(:fixture_path) { not_a_bag_path }

      it { is_expected.to be false }
    end
  end

  describe '#records' do
    subject(:records) { parser.records }

    # iterable
    it { is_expected.to be_an Array }

    # one InputRecord per bag (doesn't count files)
    its(:length) { is_expected.to eq 1 }
    its(:first) { is_expected.to be_a Darlingtonia::InputRecord }
  end
end
