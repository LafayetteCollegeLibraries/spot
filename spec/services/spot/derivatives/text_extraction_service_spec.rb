# frozen_string_literal: true
RSpec.describe Spot::Derivatives::TextExtractionService, derivatives: true do
  let(:service) { described_class.new(file_set) }
  let(:file_set) { instance_double('FileSet', mime_type: fs_mime_type, uri: '<file_set uri>') }
  let(:fs_mime_type) { 'application/pdf' }
  let(:fs_uri) { 'http://example.org/' }
  let(:src_path) { '' }

  describe '#create_derivatives' do
    before do
      allow(Hyrax.config).to receive(:extract_full_text?).and_return(true)
      allow(Hydra::Derivatives::FullTextExtract).to receive(:create)
    end

    it 'calls Hydra::Derivatives::FullTextExtract' do
      service.create_derivatives(src_path)

      expect(Hydra::Derivatives::FullTextExtract)
        .to have_received(:create)
        .with(src_path, outputs: [{ url: file_set.uri, container: 'extracted_text' }])
    end

    context 'when using a Valkyrized file_set' do
      let(:file_set) { Struct.new(:mime_type, :file_set_id).new(fs_mime_type, file_set_id) }
      let(:file_set_id) { fs_uri }

      it 'uses file_set.file_set_id.to_s' do
        service.create_derivatives(src_path)

        expect(Hydra::Derivatives::FullTextExtract)
          .to have_received(:create)
          .with(src_path, outputs: [{ url: file_set_id, container: 'extracted_text' }])
      end
    end

    context 'when disabled via Hyrax.config' do
      before do
        allow(Hyrax.config).to receive(:extract_full_text?).and_return(false)
      end

      it 'does not call Hydra::Derivatives::FullTextExtract' do
        service.create_derivatives(src_path)

        expect(Hydra::Derivatives::FullTextExtract).not_to have_received(:create)
      end
    end
  end

  describe '#valid?' do
    subject { service.valid? }

    # valid mime_types
    ['application/pdf'].each do |mime_type|
      context "when mime_type is #{mime_type}" do
        let(:fs_mime_type) { mime_type }

        it { is_expected.to be true }
      end
    end

    # invalid mime_types
    ['image/tiff', 'application/vnd.ms-excel', 'video/mpeg', 'audio/wav'].each do |mime_type|
      context "when mime_type is #{mime_type}" do
        let(:fs_mime_type) { mime_type }

        it { is_expected.to be false }
      end
    end
  end
end
