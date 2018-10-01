RSpec.describe Spot::Importers::Bag::Parser do
  subject(:parser) { described_class.new(file: fixture_path, mapper: mapper) }

  let(:fixture_path) { '/path/to/a/bagged_item'}
  let(:file_path) { ['/path/to/a/file'] }

  let(:mapper) { double('mapper') }

  let(:raw_data) do
    [
      ['key', 'value'],
      ['Multiple', 'One value;Two value'],
      ['Nil', nil]
    ]
  end

  before do
    allow(parser).to receive(:file_list).and_return file_path
    allow(parser).to receive(:csv_contents).and_return raw_data
  end

  describe '#records' do
    let(:records) { [input_record] }
    let(:input_record) { double('input record') }

    before do
      allow(parser).to receive(:input_record_from).and_return input_record
    end

    context 'when a block is given' do
      it 'yields an array with a single input record' do
        expect { |b| parser.records(&b) }.to yield_with_args records
      end
    end

    context 'when no block is given' do
      it 'returns an array with a single input record' do
        expect(parser.records).to eq records
      end
    end
  end

  # private methods
  # ~~~~~~~~~~
  #
  # like, I know that private methods should be tested by testing
  # the public methods that call them, but these can be a little
  # wonky and I want to make sure they're okay without making them
  # public to do so.

  describe '#excluded_representatives' do
    subject { parser.send(:excluded_representatives) }

    it { is_expected.to include 'license.txt', 'metadata.csv' }
    it { is_expected.to include 'bagged_item_metadata.csv' }
  end

  describe '#parse_csv_metadata' do
    subject(:metadata) { parser.send(:parse_csv_metadata) }

    it 'skips headers' do
      expect(metadata).to_not include 'key'
    end

    it 'splits values with a semi-colon' do
      expect(metadata['Multiple']).to eq ['One value', 'Two value']
    end

    it 'handles nil values' do
      expect(metadata['Nil']).to eq []
    end
  end

  describe '#path_to_csv' do
    subject { parser.send(:path_to_csv) }

    before do
      allow(File).to receive(:exist?).and_return false
      allow(File).to receive(:exist?).with(path).and_return true
    end

    context 'when metadata.csv exists' do
      let(:path) { File.join(fixture_path, 'data', 'metadata.csv') }

      it { is_expected.to eq path }
    end

    context 'when a file prefixed with the bag_uid exists' do
      let(:path) do
        File.join(fixture_path,
                  'data',
                  "#{File.basename(fixture_path)}_metadata.csv")
      end

      it { is_expected.to eq path }
    end

    context 'when the expected files do not exist' do
      let(:path) { '/not/a/valid/file.csv' }

      it { is_expected.to be nil }
    end
  end
end
