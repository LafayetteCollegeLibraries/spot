# frozen_string_literal: true
RSpec.shared_examples 'it handles required fields' do |*fields|
  describe '.required_fields' do
    subject { described_class.required_fields }

    it { is_expected.to contain_exactly(*fields) }
  end

  describe '.terms' do
    subject { described_class.terms }

    it { is_expected.to include(*fields) }
  end
end
