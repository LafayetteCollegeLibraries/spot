# frozen_string_literal: true
RSpec.describe Spot::FileSetDerivativesService, derivatives: true do
  let(:service) { described_class.new(file_set) }
  let(:file_set) { build(:file_set) }
  let(:fs_mime_type) { 'image/tiff' }
  let(:derivative_service_1) { instance_double('Hyrax::DerivativeService') }
  let(:derivative_service_2) { instance_double('Hyrax::DerivativeService') }
  let(:service_1_valid) { false }
  let(:service_2_valid) { false }
  let(:services) do
    [
      class_double('Hyrax::DerivativeService', new: derivative_service_1),
      class_double('Hyrax::DerivativeService', new: derivative_service_2)
    ]
  end

  # rubocop:disable RSpec/InstanceVariable
  before do
    allow(file_set).to receive(:mime_type).and_return(fs_mime_type)
    allow(derivative_service_1).to receive(:valid?).and_return(service_1_valid)
    allow(derivative_service_1).to receive(:cleanup_derivatives)
    allow(derivative_service_1).to receive(:create_derivatives)
    allow(derivative_service_2).to receive(:valid?).and_return(service_2_valid)
    allow(derivative_service_2).to receive(:cleanup_derivatives)
    allow(derivative_service_2).to receive(:create_derivatives)

    @original_services = described_class.derivative_services
    described_class.derivative_services = services
  end

  after do
    described_class.derivative_services = @original_services
  end
  # rubocop:enable RSpec/InstanceVariable

  it_behaves_like 'a Hyrax::DerivativeService' do
    let(:valid_file_set) { build(:file_set) }
    let(:service_1_valid) { true } # required for service.valid?
  end

  describe '#cleanup_derivatives' do
    context 'when all services are valid' do
      let(:service_1_valid) { true }
      let(:service_2_valid) { true }

      it 'calls #cleanup_derivatives on each' do
        service.cleanup_derivatives

        expect(derivative_service_1).to have_received(:cleanup_derivatives)
        expect(derivative_service_2).to have_received(:cleanup_derivatives)
      end
    end

    context 'when not all services are valid' do
      let(:service_1_valid) { true }
      let(:service_2_valid) { false }

      it 'calls #cleanup_derivatives on each' do
        service.cleanup_derivatives

        expect(derivative_service_1).to have_received(:cleanup_derivatives)
        expect(derivative_service_2).not_to have_received(:cleanup_derivatives)
      end
    end
  end

  describe '#create_derivatives' do
    let(:src_path) { '/path/to/file.png' }

    context 'when all services are valid' do
      let(:service_1_valid) { true }
      let(:service_2_valid) { true }

      it 'calls #create_derivatives on each' do
        service.create_derivatives(src_path)

        expect(derivative_service_1).to have_received(:create_derivatives).with(src_path)
        expect(derivative_service_2).to have_received(:create_derivatives).with(src_path)
      end
    end

    context 'when not all services are valid' do
      let(:service_1_valid) { true }
      let(:service_2_valid) { false }

      it 'calls #cleanup_derivatives on each' do
        service.create_derivatives(src_path)

        expect(derivative_service_1).to have_received(:create_derivatives).with(src_path)
        expect(derivative_service_2).not_to have_received(:create_derivatives)
      end
    end

    describe '#valid?' do
      subject { described_class.new(file_set).valid? }

      context 'when any of the services are valid' do
        let(:service_1_valid) { true }
        let(:service_2_valid) { false }

        it { is_expected.to be true }
      end

      context 'when none of the services are valid' do
        let(:service_1_valid) { false }
        let(:service_2_valid) { false }

        it { is_expected.to be false }
      end
    end
  end
end
