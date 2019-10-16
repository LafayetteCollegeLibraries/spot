# frozen_string_literal: true
RSpec.describe Spot::FileSetIndexer do
  subject(:solr_doc) { indexer.generate_solr_document }

  let(:indexer) { described_class.new(file_set) }
  let(:file_set) { build(:file_set, label: 'file_set_object') }
  let(:mock_file) { instance_double(Hydra::PCDM::File) }

  before do
    allow(file_set).to receive(:extracted_text).and_return(mock_file)
    allow(mock_file).to receive(:present?).and_return(true)
    allow(mock_file).to receive(:content).and_return('some text')
  end

  describe '"all_text_timv"' do
    it { is_expected.not_to include 'all_text_timv' }
  end
end
