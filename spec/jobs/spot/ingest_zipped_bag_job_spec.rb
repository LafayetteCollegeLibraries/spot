require 'tmpdir'

RSpec.describe Spot::IngestZippedBagJob do
  subject(:job) do
    described_class.perform_now(zip_path: zip_path,
                                work_class: work_class,
                                source: source,
                                working_path: working_path)
  end

  let(:working_path) { Rails.root.join('tmp') }
  let(:zip_path) { '/path/to/bag.zip' }
  let(:work_class) { 'Publication' }
  let(:source) { 'ldr' }
  let(:zip_service_double) { double('zip service') }

  describe '#perform' do
    before do
      allow(ZipService)
        .to receive(:new)
        .with(src_path: zip_path)
        .and_return(zip_service_double)

      allow(zip_service_double)
        .to receive(:unzip!)
        .with(dest_path: working_path.join('bag').to_s)
    end

    it 'unzips the bag and passes it to Spot::IngestBagJob' do
      expect(Spot::IngestBagJob)
        .to receive(:perform_now)
        .with(bag_path: working_path.join('bag').to_s,
              source: source,
              work_class: work_class)

      job
    end

    context 'when working path isn\'t a directory' do
      let(:working_path) { Pathname.new('/nope/not/here') }

      it 'raises an ArgumentError' do
        expect { job }
          .to raise_error(ArgumentError, /is not a directory/)
      end
    end
  end
end
