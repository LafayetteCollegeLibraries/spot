# frozen_string_literal: true
RSpec.shared_examples 'it maps original create date' do
  describe '#date_uploaded' do
    subject { mapper.date_uploaded }

    let(:mapper) { described_class.new }
    let(:field) { described_class.original_create_date_field }
    let(:metadata) { field => value }

    before { mapper.metadata = metadata }

    context 'when a valid value exists' do
      let(:value) { '2015-04-14 15:55:52' }

      it { is_expected.to eq value }
    end

    context 'when the value is not valid' do
      let(:value) { 'not a date :(' }

      it { is_expected.to be_nil }
    end

    context 'when the metadata does not contain the field' do
      let(:metadata) { { 'title' => ['a title'] } }

      it { is_expected.to be_nil }
    end
  end
end
