# frozen_string_literal: true
RSpec.describe Spot::PdfDerivativesService do
  subject(:service) { described_class.new(valid_file_set) }

  before do
    allow(valid_file_set).to receive(:mime_type).and_return('application/pdf')

    allow(::Spot::Derivatives::ThumbnailService).to receive(:new).and_return(thumbnail_service)
  end

  let(:valid_file_set) { FileSet.new }
  let(:thumbnail_service) { instance_double(::Spot::Derivatives::ThumbnailService) }

  # since we're delegating +:derivative_url+ to the individual
  # derivative services, and not defining one in this service,
  # using the +it_behaves_like 'a Hyrax::DerivativeService'+
  # shared_spec will fail. instead, we'll spell out those tasks here

  describe 'behaves like a Hyrax::DerivativeService (sort of)' do
    it { is_expected.to respond_to(:cleanup_derivatives).with(0).arguments }
    it { is_expected.to respond_to(:create_derivatives).with(1).arguments }
    it { is_expected.to respond_to(:file_set) }
    it { is_expected.to respond_to(:mime_type) }
  end

  it 'is the service for PDFs' do
    expect(Hyrax::DerivativeService.for(valid_file_set).class).to eq described_class
  end

  describe '#cleanup_derivatives' do
    before do
      allow(thumbnail_service).to receive(:cleanup_derivatives)
    end

    it 'calls +#cleanup_derivatives+ on both of the services' do
      service.cleanup_derivatives

      expect(thumbnail_service).to have_received(:cleanup_derivatives)
    end
  end

  describe '#create_derivatives' do
    let(:filename) { '/path/to/an/asset.pdf' }

    before do
      allow(thumbnail_service).to receive(:create_derivatives)
    end

    it 'calls +#create_derivatives+ on the thumbnail services' do
      service.create_derivatives(filename)

      expect(thumbnail_service).to have_received(:create_derivatives).with(filename)
    end
  end

  describe '#valid?' do
    subject { service.valid? }

    it { is_expected.to be true }
  end
end
