RSpec.describe Spot::Importers::Bag::Parser do
  subject(:parser) do
    described_class.new(directory: bag_path, mapper: mapper)
  end

  let(:fixture_path) { Rails.root.join('spec', 'fixtures') }
  let(:bag_path) { Rails.root.join('spec', 'fixtures', 'sample-bag') }
  let(:mapper) { Spot::Mappers::BaseMapper.new }
  let(:file_list) { ['image.png'] }

  before do
    mapper.class.fields_map = { title: 'title', keyword: 'keyword' }
  end

  describe '#records' do
    subject(:records) { parser.records }

    it { is_expected.to be_an Array }

    it 'should only contain one item' do
      expect(records.size).to eq 1
    end

    describe 'the input record' do
      subject(:input_record) { records.first }

      it { is_expected.to be_a Darlingtonia::InputRecord }
    end

    describe 'the metadata' do
      subject(:metadata) { records.first.mapper.metadata }

      it { is_expected.to be_a Hash }
      it { is_expected.to include 'title' }
      it { is_expected.to include 'keyword' }
      it { is_expected.to include 'license' }
      it { is_expected.to include 'representative_files' }

      describe 'the representative files' do
        subject(:files) { metadata['representative_files'] }

        let(:file_path) { File.join(bag_path, 'data', 'files', 'image.png') }

        it { is_expected.to eq [file_path.to_s] }
      end
    end
  end
end
