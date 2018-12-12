require 'tmpdir'

RSpec.describe Spot::Validators::BagMetadataValidator do
  subject(:validator) { described_class.new(error_stream: error_stream) }

  let(:error_stream) { File.open(File::NULL, 'w') }
  let(:parser) { double('parser') }
  let(:fixtures_path) { Rails.root.join('spec', 'fixtures') }
  let(:bag) { fixtures_path.join('sample-bag') }

  before do
    allow(parser).to receive(:file).and_return(bag)
  end

  describe '#validate' do
    subject { validator.validate(parser: parser) }

    context 'when a metadata.csv file exists' do
      it { is_expected.to be_empty }
    end

    context 'when a metadata.csv file does not exist' do
      Dir.mktmpdir do |dir|
        let(:bag) { dir }

        it { is_expected.not_to be_empty }
        it { is_expected.to include 'Bag does not have a "data/metadata.csv" file' }
      end
    end
  end
end
