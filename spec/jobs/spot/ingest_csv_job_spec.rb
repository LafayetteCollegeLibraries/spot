# frozen_string_literal: true
RSpec.describe Spot::IngestCSVJob do
  let(:metadata_path) { '/path/to/ingest/metadata.csv' }
  let(:source_path) { '/path/to/ingest/files' }
  let(:work_type) { :publication }
  let(:collection_ids) { ['col123def'] }
  let(:admin_set_id) { 'admin_set/kool_things' }
  let(:file_double) { double }

  before do
    allow(File).to receive(:open).with(metadata_path, 'r').and_return(file_double)
    allow(Spot::CSVIngestService).to receive(:perform)
    described_class.perform_now(metadata_path: metadata_path,
                                source_path: source_path,
                                work_type: work_type,
                                collection_ids: collection_ids,
                                admin_set_id: admin_set_id)
  end

  it 'passes params to the CSVIngestService' do
    expect(Spot::CSVIngestService)
      .to have_received(:perform)
      .with(file: file_double,
            source_path: source_path,
            work_type: work_type,
            collection_ids: collection_ids,
            admin_set_id: admin_set_id)
  end
end
