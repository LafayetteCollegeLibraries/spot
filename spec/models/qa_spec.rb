# frozen_string_literal: true
RSpec.describe Qa do
  describe '.table_name_prefix' do
    subject { described_class.table_name_prefix }

    it { is_expected.to eq 'qa_' }
  end
end
