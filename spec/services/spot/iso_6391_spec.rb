# frozen_string_literal: true
RSpec.describe Spot::ISO6391 do
  describe '.all' do
    subject { described_class.all }

    it { is_expected.to be_a Hash }
    it { is_expected.not_to be_empty }
  end

  describe '.label_for' do
    subject { described_class.label_for(id) }

    context 'when a 2-char entry exists' do
      let(:id) { 'eo' }

      it { is_expected.to eq 'Esperanto' }
    end

    context 'when a local override for an entry exists' do
      let(:id) { 'en' }
      let(:original_value) { ISO_639.find(id).english_name }
      let(:expected_value) { 'ANGLISH' }

      before do
        allow(I18n)
          .to receive(:t)
          .with(id, { default: [original_value, id], scope: ['iso_639_1'] })
          .and_return(expected_value)
      end

      it { is_expected.not_to eq original_value }
      it { is_expected.to eq expected_value }
    end

    context 'when an entry does not exist' do
      let(:id) { ':(' }

      it { is_expected.to eq id }
    end
  end
end
