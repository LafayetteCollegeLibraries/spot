# frozen_string_literal: true
RSpec.describe Spot::IngestDOIJob do
  subject(:perform_job!) do
    described_class.perform_now(doi: doi, work_class: work_class)
  end

  let(:work_class) { 'Publication' }
  let(:doi) { '00.000/abc123/def456' }

  describe '#perform' do
    before do
      allow(Darlingtonia::Importer).to receive(:new).and_return(importer_double)
    end

    let(:importer_double) { instance_double('Darlingtonia::Importer', import: true) }

    context 'when a work_class is not registered' do
      let(:work_class) { 'Spot' }

      it 'raises an ArgumentError' do
        expect { perform_job! }
          .to raise_error(ArgumentError, /Unknown work_class: #{work_class}/)
      end
    end

    context 'when everything is ok' do
      before { perform_job! }

      it 'calls importer#import' do
        expect(importer_double).to have_received(:import)
      end
    end
  end
end
