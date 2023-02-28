# frozen_string_literal: true
RSpec.describe Spot::CollectionThumbnailPathService do
  describe '.call' do
    subject { described_class.call(collection) }

    let(:collection) { instance_double(Collection, id: 'colabc123') }
    let(:file_path) { Rails.root.join('spec', 'fixtures', 'work.png').to_s }
    let(:mock_branding_storage_adapter) { double(delete: true, upload: true) }

    before do
      # need to block CollectionBrandingInfo from deleting our fixture image
      allow(Hyrax.config).to receive(:branding_storage_adapter).and_return(mock_branding_storage_adapter)
      allow(FileUtils).to receive(:remove_file).with(file_path).and_return(true)
    end

    after do
      CollectionBrandingInfo.where(collection_id: collection.id)&.delete_all
    end

    context 'when a collection has a CollectionBrandingInfo object' do
      before do
        branding = CollectionBrandingInfo.new(
          collection_id: collection.id,
          role: 'logo',
          filename: 'work.png'
        )

        branding.save(file_path)
      end

      it { is_expected.to eq '/branding/colabc123/logo/work.png' }
    end

    context 'when no CollectionBrandingInfo for collection exists' do
      before do
        allow(Hyrax::CollectionThumbnailPathService).to receive(:call).with(collection)
      end

      it 'calls the super method' do
        described_class.call(collection)

        expect(Hyrax::CollectionThumbnailPathService)
          .to have_received(:call)
          .with(collection)
      end
    end
  end
end
