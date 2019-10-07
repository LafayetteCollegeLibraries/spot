# frozen_string_literal: true

# RSpec.describe FixityCheckBatch do; end

RSpec.describe FixityCheckBatch::Summary do
  subject(:summary) { described_class.new(opts) }

  let(:opts) do
    { success: success_count, failed: failed_count,
      failed_item_ids: failed_item_ids, total_time: total_time }
  end

  let(:success_count) { 0 }
  let(:failed_count) { 0 }
  let(:failed_item_ids) { [] }
  let(:total_time) { 0.0 }

  describe '.load' do
    subject(:summary) { described_class.load(json) }

    context 'with an empty object' do
      let(:json) { '' }

      it { is_expected.to be_nil }
    end

    context 'with values' do
      let(:json) { '{"success": 100, "failed": 0, "failed_item_ids": [], "total_time": 0.0 }' }

      it 'loads a new object with the values' do
        expect(summary.success).to eq 100
        expect(summary.failed).to eq 0
        expect(summary.failed_item_ids).to eq []
        expect(summary.total_time).to eq 0.0
      end
    end
  end

  describe '.dump' do
    subject { described_class.dump(summary) }

    let(:dumped) { '{"success":100,"failed":0,"failed_item_ids":[],"total_time":0.0}' }

    context 'when summary is a Summary object' do
      let(:summary) { described_class.new(success: 100, failed: 0, failed_item_ids: [], total_time: 0.0) }

      it { is_expected.to eq dumped }
    end

    context 'when a summary is a Hash' do
      let(:summary) { { 'success' => 100, 'failed' => 0, 'failed_item_ids' => [], 'total_time' => 0.0 } }

      it { is_expected.to eq dumped }
    end

    context 'otherwise it raises' do
      it do
        expect { described_class.dump(nil) }
          .to raise_error(StandardError, "Expected FixityCheckBatch::Summary or Hash, got NilClass")
      end
    end
  end

  describe '#to_h' do
    subject(:hash) { summary.to_h }

    it { is_expected.to be_a Hash }
    it { is_expected.to include(:success, :failed, :failed_item_ids, :total_time) }
  end
end
