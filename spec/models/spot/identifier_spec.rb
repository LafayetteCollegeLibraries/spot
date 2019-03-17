# frozen_string_literal: true
RSpec.describe Spot::Identifier do
  describe '.from_string' do
    subject(:id) { described_class.from_string(raw_string) }

    let(:prefix) { 'hdl' }
    let(:value) { '123:456/lol' }
    let(:raw_string) { "#{prefix}:#{value}" }

    it 'captures the prefix' do
      expect(id.prefix).to eq prefix
    end

    it 'captures the value' do
      expect(id.value).to eq value
    end

    context 'when input has no prefix' do
      let(:raw_string) { 'just an identifier' }

      it 'sets the prefix to nil' do
        expect(id.prefix).to be_nil
      end
    end
  end

  describe '.prefixes' do
    subject { described_class.standard_prefixes }

    it { is_expected.to include 'doi', 'issn', 'isbn', 'hdl', 'oclc' }
  end

  describe '.prefix_label' do
    subject { described_class.prefix_label(prefix) }

    let(:t_prefix_string) { "spot.identifiers.labels.#{prefix}" }
    let(:default) { prefix.titleize }

    context 'when a translation exists' do
      before do
        allow(I18n)
          .to receive(:t)
          .with(t_prefix_string, default: default)
          .and_return(translation)
      end

      let(:translation) { 'ISBN' }
      let(:prefix) { 'isbn' }

      it { is_expected.to eq translation }
    end

    context 'when a translation does not exist' do
      let(:prefix) { 'not an existing prefix' }

      it { is_expected.to eq default }
    end
  end

  describe '#prefix_label' do
    before do
      allow(described_class).to receive(:prefix_label)
    end

    let(:prefix) { 'hdl' }

    it "calls #{described_class}.prefix_label" do
      described_class.new(prefix, nil).prefix_label

      expect(described_class).to have_received(:prefix_label).with(prefix, default: prefix.titleize)
    end
  end

  describe '#standard?' do
    subject { identifier.standard? }

    let(:identifier) { described_class.from_string(id) }

    context 'when a standard prefix' do
      let(:id) { 'isbn:9783908247692' }

      it { is_expected.to be true }
    end

    context 'when non-standard' do
      let(:id) { 'lafayette_magazine:123' }

      it { is_expected.to be false }
    end
  end

  describe '#local?' do
    subject { identifier.local? }

    let(:identifier) { described_class.from_string(id) }

    context 'when a standard prefix' do
      let(:id) { 'isbn:9783908247692' }

      it { is_expected.to be false }
    end

    context 'when non-standard' do
      let(:id) { 'lafayette_magazine:123' }

      it { is_expected.to be true }
    end
  end

  describe '#to_s' do
    subject { described_class.new(prefix, value).to_s }

    let(:prefix) { 'prefix' }
    let(:value) { 'value' }

    it { is_expected.to eq "#{prefix}:#{value}" }

    context 'when no value is present' do
      let(:prefix) { '' }
      let(:value) { '' }

      it { is_expected.to eq '' }
    end

    context 'when no prefix is present' do
      let(:prefix) { '' }

      it { is_expected.to eq value.to_s }
    end
  end
end
