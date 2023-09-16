# frozen_string_literal: true
RSpec.describe Spot::VirusScanner do
  describe '.infected?' do
    subject { described_class.infected?(file_path) }

    let(:file_path) { '/path/to/a/file' }

    before do
      allow(Clamby).to receive(:virus?).with(file_path).and_return(verdict)
    end

    context 'when file_path has a virus' do
      let(:verdict) { true }

      it { is_expected.to be true }
    end

    context 'when file_path is clean' do
      let(:verdict) { false }

      it { is_expected.to be false }
    end
  end
end
