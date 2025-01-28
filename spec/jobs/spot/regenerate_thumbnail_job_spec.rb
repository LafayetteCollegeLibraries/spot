# frozen_string_literal: true
RSpec.describe Spot::RegenerateThumbnailJob, valkyrization: true do
  let(:work) { instance_double(Publication, id: 'pub123abc', thumbnail_id: thumbnail_id) }
  let(:file_set) { instance_double(FileSet, id: 'fst123abc') }
  let(:thumbnail_id) { file_set.id }
  let(:thumbnail_service_double) { instance_double(Spot::Derivatives::ThumbnailService) }
  let(:thumbnail_path) { '/path/to/thumbnail.jpg' }

  before do
    allow(Hyrax::DerivativePath)
      .to receive(:derivative_path_for_reference)
      .with(file_set, 'thumbnail')
      .and_return(thumbnail_path)

    allow(Spot::Derivatives::ThumbnailService)
      .to receive(:new)
      .and_return(thumbnail_service_double)

    allow(Hyrax.query_service).to receive(:find_by_alternate_identifier).with(alternate_identifier: thumbnail_id).and_return(file_set)
    allow(Hyrax.persister).to receive(:save)

    allow(thumbnail_service_double).to receive(:create_derivatives).with(thumbnail_path)
  end

  describe '#perform' do
    it 'generates a thumbnail and updates the index' do
      described_class.perform_now(work)

      expect(thumbnail_service_double).to have_received(:create_derivatives).with(thumbnail_path)
      expect(Hyrax.persister).to have_received(:save).exactly(2).times
    end

    context 'when a work does not have a thumbnail_id' do
      let(:thumbnail_id) { nil }

      it 'bails early' do
        expect(described_class.perform_now(work)).to be nil

        expect(thumbnail_service_double).not_to have_received(:create_derivatives)
      end
    end

    context 'when a work no longer exists' do
      before do
        allow(Rails.logger).to receive(:warn)

        allow(Hyrax.query_service)
          .to receive(:find_by_alternate_identifier)
          .with(alternate_identifier: thumbnail_id)
          .and_raise(::Valkyrie::Persistence::ObjectNotFoundError)
      end

      it 'logs a warning' do
        described_class.perform_now(work)
        expect(Rails.logger).to have_received(:warn).with("Unable to regenerate thumbnail for deleted work #{work.id}")
      end
    end
  end
end
