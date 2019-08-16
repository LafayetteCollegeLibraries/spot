# frozen_string_literal: true
require 'tmpdir'

RSpec.describe Spot::IngestZippedBagJob do
  subject(:job) do
    described_class.perform_now(zip_path: zip_path,
                                work_class: work_class,
                                source: source,
                                collection_ids: collection_ids,
                                multi_value_character: ';',
                                working_path: working_path)
  end

  let(:working_path) { Rails.root.join('tmp') }
  let(:zip_path) { '/path/to/bag.zip' }
  let(:work_class) { 'Publication' }
  let(:source) { 'ldr' }
  let(:zip_service_double) { instance_double(ZipService, unzip!: true) }
  let(:collection_ids) { ['abc123def'] }

  describe '#perform' do
    before do
      allow(ZipService).to receive(:new).and_return(zip_service_double)

      allow(Spot::IngestBagJob).to receive(:perform_now)
    end

    it 'unzips the bag and passes it to Spot::IngestBagJob' do
      job

      expect(Spot::IngestBagJob)
        .to have_received(:perform_now)
        .with(bag_path: working_path.join('bag').to_s, source: source,
              work_class: work_class, collection_ids: collection_ids, multi_value_character: ';')
    end

    context 'when working path isn\'t a directory' do
      let(:working_path) { Pathname.new('/nope/not/here') }

      it 'raises an ArgumentError' do
        expect { job }.to raise_error(ArgumentError, /is not a directory/)
      end
    end
  end
end
