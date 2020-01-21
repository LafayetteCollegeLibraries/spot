# frozen_string_literal: true
RSpec.describe Spot::IngestBagJob do
  let(:source) { 'ldr' }
  let(:mapper_klass) { Spot::Mappers.get(source) }
  let(:work_klass) { 'Publication' }
  let(:fixtures_path) { Rails.root.join('spec', 'fixtures') }
  let(:bag_path) { fixtures_path.join('sample-bag') }
  let(:service_double) { instance_double(Spot::BagIngestService, ingest: true) }
  let(:service_args) do
    { path: bag_path, work_klass: work_klass.constantize,
      mapper_klass: mapper_klass, collection_ids: [], logger: Rails.logger }
  end

  before do
    allow(Spot::BagIngestService)
      .to receive(:new)
      .with(**service_args)
      .and_return(service_double)
  end

  describe '#perform' do
    it 'passes arguments to Spot::BagIngestService' do
      described_class.perform_now(work_klass: work_klass, source: source, path: bag_path)

      expect(Spot::BagIngestService).to have_received(:new).with(**service_args)
      expect(service_double).to have_received(:ingest)
    end
  end
end
