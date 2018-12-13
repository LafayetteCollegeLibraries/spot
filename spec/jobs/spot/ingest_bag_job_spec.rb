# frozen_string_literal: true
RSpec.describe Spot::IngestBagJob do
  subject(:job) do
    described_class.perform_now(work_class: work_class,
                                source: source,
                                bag_path: bag_path)
  end

  let(:source) { 'ldr' }
  let(:work_class) { 'Publication' }
  let(:fixtures_path) { Rails.root.join('spec', 'fixtures') }
  let(:bag_path) { fixtures_path.join('sample-bag') }
  let(:importer_double) { instance_double(Darlingtonia::Importer, import: true) }

  before do
    allow(Darlingtonia::Importer)
      .to receive(:new)
      .and_return(importer_double)
  end

  describe '#perform' do
    context 'when a source is unknown' do
      let(:source) { 'kewl_source' }
      it 'raises an ArgumentError' do
        expect { job }
          .to raise_error(ArgumentError, /Unknown source: #{source}/)
      end
    end

    context 'when a work_class isn\'t registered' do
      let(:work_class) { 'Spot' }

      it 'raises an ArgumentError' do
        expect { job }
          .to raise_error(ArgumentError, /Unknown work_class: #{work_class}/)
      end
    end

    context 'when the bag validates okay' do
      it 'calls #import on the importer' do
        job

        expect(importer_double).to have_received(:import)
      end
    end

    context 'when the bag does not validate' do
      let(:parser_double) do
        instance_double(Spot::Importers::Bag::Parser, validate!: false)
      end

      before do
        allow(Spot::Importers::Bag::Parser)
          .to receive(:new)
          .and_return(parser_double)
      end

      it 'does nothing' do
        job

        expect(importer_double).not_to have_received(:import)
      end
    end
  end
end
