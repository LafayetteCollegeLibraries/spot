# frozen_string_literal: true
RSpec.describe Spot::IiifService do
  subject(:service) { described_class.new(file_id: file_id) }

  before do
    stub_env('IIIF_URL_BASE', 'http://localhost/iiif/2')
  end

  let(:file_id) { 'abc123def/files/00000000-0000-0000-0000-000000000000' }

  describe '.download_url' do
    subject { described_class.download_url(file_id: file_id, size: '500,', filename: 'image.jpg') }

    it { is_expected.to eq 'http://localhost/iiif/2/abc123def/full/500,/0/default.jpg?response-content-disposition=attachment%3B%20image.jpg' }
  end

  describe '#download_url' do
    context 'without any arguments' do
      subject { service.download_url }

      it { is_expected.to eq 'http://localhost/iiif/2/abc123def/full/600,/0/default.jpg?response-content-disposition=attachment%3B%20abc123def.jpg' }
    end

    context 'with a filename provided' do
      subject { service.download_url(filename: 'work-id.jpeg') }

      it { is_expected.to eq 'http://localhost/iiif/2/abc123def/full/600,/0/default.jpg?response-content-disposition=attachment%3B%20work-id.jpeg' }
    end

    context 'with arguments provided' do
      subject { service.download_url(region: '100,100', size: '100,100', rotation: '180', quality: 'gray', format: 'tif', filename: 'gray-work.tif') }

      it { is_expected.to eq 'http://localhost/iiif/2/abc123def/100,100/100,100/180/gray.tif?response-content-disposition=attachment%3B%20gray-work.tif' }
    end
  end

  describe '.image_url' do
    subject { described_class.image_url(file_id, 'http://noop.global', '500,') }

    it { is_expected.to eq 'http://localhost/iiif/2/abc123def/full/500,/0/default.jpg' }
  end

  describe '#image_url' do
    context 'without any arguments' do
      subject { service.image_url }

      it { is_expected.to eq 'http://localhost/iiif/2/abc123def/full/600,/0/default.jpg' }
    end

    context 'with arguments provided' do
      subject { service.image_url(region: '100,100', size: '100,100', rotation: '180', quality: 'gray', format: 'tif') }

      it { is_expected.to eq 'http://localhost/iiif/2/abc123def/100,100/100,100/180/gray.tif' }
    end
  end

  describe '.info_url' do
    subject { described_class.info_url(file_id, 'http://noop.global/iiif/2') }

    # viewer appends info.json i believe
    it { is_expected.to eq 'http://localhost/iiif/2/abc123def' }
  end
end
