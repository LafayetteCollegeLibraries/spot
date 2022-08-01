# frozen_string_literal: true
RSpec.describe Spot::CSVIngestService, feature: :csv_ingest_service do
  describe '.perform' do
    let(:mock_parser) { instance_double(Spot::Importers::CSV::Parser, validate!: validate_response) }
    let(:mock_record_importer) { instance_double(Spot::Importers::CSV::RecordImporter) }
    let(:mock_importer) { instance_double(Darlingtonia::Importer, import: true) }
    let(:validate_response) { true }
    let(:file) { instance_double(File) }
    let(:work_type) { :publication }
    let(:source_path) { '/path/to/new_ingest' }
    let(:collection_ids) { [] }
    let(:admin_set_id) { 'an_admin_set' }

    before do
      allow(Spot::Importers::CSV::Parser)
        .to receive(:new)
        .with(file: file, work_type: work_type)
        .and_return(mock_parser)

      allow(Spot::Importers::CSV::RecordImporter)
        .to receive(:new)
        .with(source_path: source_path,
              collection_ids: collection_ids,
              admin_set_id: admin_set_id)
        .and_return(mock_record_importer)

      allow(Darlingtonia::Importer)
        .to receive(:new)
        .with(parser: mock_parser, record_importer: mock_record_importer)
        .and_return(mock_importer)
    end

    context 'if the parser validates' do
      it 'calls importer#import' do
        described_class.perform(file: file,
                                source_path: source_path,
                                work_type: work_type,
                                collection_ids: collection_ids,
                                admin_set_id: admin_set_id)

        expect(mock_importer).to have_received(:import)
      end
    end

    it 'does nothing if the parser does not validate' do
      # expect()
    end
  end
end
