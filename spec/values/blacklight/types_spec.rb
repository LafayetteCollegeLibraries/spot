# frozen_string_literal: true
RSpec.describe Blacklight::Types do
  describe 'Array' do
    subject { described_class::Array.coerce(value) }

    context 'when an Array' do
      let(:value) { ['a value'] }

      it { is_expected.to eq value }
    end

    context 'when another value' do
      let(:value) { 'a value' }

      it { is_expected.to eq [value] }
    end
  end

  describe 'String' do
    subject { described_class::String.coerce(value) }

    context 'when a single value' do
      let(:value) { 'a single value' }

      it { is_expected.to eq value }
    end

    context 'when an array' do
      let(:value) { ['one', 'two'] }

      it { is_expected.to eq value.first }
    end
  end

  describe 'Date' do
    subject { described_class::Date.coerce(value) }

    context 'when a parseable date' do
      let(:value) { Time.now.utc.to_s }

      it { is_expected.to be_a Date }
    end

    context 'when not parseable' do
      let(:value) { 'not today' }

      it { is_expected.to be true }
    end
  end
end
