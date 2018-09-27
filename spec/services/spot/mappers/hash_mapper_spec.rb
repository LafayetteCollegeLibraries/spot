RSpec.describe Spot::Mappers::HashMapper do
  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  before do
    mapper.metadata = metadata
  end

  describe '#representative_file' do
    subject { mapper.representative_file }

    let(:paths) { ['/path/to/file', '/path/to/another'] }
    let(:metadata) { {representative_files: paths} }

    it { is_expected.to eq paths }
  end
end
