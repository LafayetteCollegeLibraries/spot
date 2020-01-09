# frozen_string_literal: true
RSpec.describe Spot::BagIngestService do
  subject(:service) do
    described_class.new(path: bag_path, work_klass: work_class, mapper_klass: mapper_klass).ingest
  end

  let(:mapper_klass) { Spot::Mappers::LdrDspaceMapper }
  let(:source) { 'ldr' }
  let(:work_class) { Publication }
  let(:fixtures_path) { Rails.root.join('spec', 'fixtures') }
  let(:bag_path) { fixtures_path.join('sample-bag') }
  let(:importer_double) { instance_double(Darlingtonia::Importer, import: true) }

  before do
    allow(Darlingtonia::Importer).to receive(:new).and_return(importer_double)
  end

  describe '#ingest' do
    context 'when a work_class isn\'t registered' do
      let(:work_class) { 'Spot' }

      it 'raises an ArgumentError' do
        expect { service }.to raise_error(ArgumentError, /Unknown work_klass: #{work_class}/)
      end
    end

    context 'when the bag validates okay' do
      it 'calls #import on the importer' do
        service

        expect(importer_double).to have_received(:import)
      end
    end

    context 'when the bag does not validate' do
      let(:parser_double) do
        instance_double(Spot::Importers::Bag::Parser, validate!: false)
      end

      before do
        allow(Spot::Importers::Bag::Parser).to receive(:new).and_return(parser_double)
      end

      it 'does nothing' do
        service

        expect(importer_double).not_to have_received(:import)
      end
    end
  end
end
