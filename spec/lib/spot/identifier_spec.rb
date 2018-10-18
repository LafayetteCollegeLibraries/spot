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

    context 'when the prefix is not supported' do
      let(:raw_string) { 'http://cool-example.org' }

      it 'does not provide a prefix' do
        expect(id.prefix).to be_nil
      end

      it 'retains the full value' do
        expect(id.value).to eq raw_string
      end
    end
  end

  describe '.prefixes' do
    subject { described_class.prefixes }

    it { is_expected.to include 'doi', 'issn', 'isbn', 'hdl', 'lafayette' }
  end

  describe '#to_s' do
    subject { described_class.new('prefix', 'value').to_s }

    it { is_expected.to eq 'prefix:value' }
  end
end
