RSpec.describe Spot::ISO6391 do
  describe '#all' do
    subject { described_class.all }

    it { is_expected.to be_a Hash }
    it { is_expected.not_to be_empty }
  end

  describe '#label_for' do
    subject { described_class.label_for(id) }

    context 'when a 2-char entry exists' do
      let(:id) { 'eo' }

      it { is_expected.to eq 'Esperanto' }
    end

    context 'when an entry does not exist' do
      let(:id) { ':(' }

      it { is_expected.to be_nil }
    end
  end
end
