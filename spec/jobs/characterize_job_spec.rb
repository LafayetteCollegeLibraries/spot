# frozen_string_literal: true
RSpec.describe CharacterizeJob do
  let(:file_set_id) { 'abc12345' }
  let(:filename)    { Rails.root.join('tmp', 'uploads', 'ab', 'c1', '23', '45', 'abc12345', 'picture.png').to_s }
  let(:file_set) do
    FileSet.new(id: file_set_id).tap do |fs|
      allow(fs).to receive(:original_file).and_return(file)
      allow(fs).to receive(:update_index)
    end
  end
  let(:file) do
    Hydra::PCDM::File.new.tap do |f|
      f.content = 'foo'
      f.original_name = 'picture.png'
      f.save!
      allow(f).to receive(:save!)
    end
  end
  let(:characterization_proxy) { file }

  before do
    allow(FileSet).to receive(:find).with(file_set_id).and_return(file_set)
    allow(Hydra::Works::CharacterizationService).to receive(:run).with(characterization_proxy, filename, ch12n_tool: tool)
    allow(CreateDerivativesJob).to receive(:perform_later).with(file_set, file.id, filename)
    allow(Hyrax::WorkingDirectory).to receive(:find_or_retrieve).and_return(filename)
  end

  shared_examples 'the Hyrax CharacterizeJob' do
    context 'with valid filepath param' do
      before { allow(File).to receive(:exist?).with(filename).and_return true }

      it 'skips Hyrax::WorkingDirectory' do
        described_class.perform_now(file_set, file.id, filename)

        expect(Hyrax::WorkingDirectory).not_to have_received(:find_or_retrieve)
        expect(Hydra::Works::CharacterizationService).to have_received(:run).with(file, filename, ch12n_tool: tool)
      end
    end

    context 'when the characterization proxy content is present' do
      it 'runs Hydra::Works::CharacterizationService and creates a CreateDerivativesJob' do
        described_class.perform_now(file_set, file.id)

        expect(Hydra::Works::CharacterizationService).to have_received(:run).with(file, filename, ch12n_tool: tool)
        expect(file).to have_received(:save!)
        expect(file_set).to have_received(:update_index)
        expect(CreateDerivativesJob).to have_received(:perform_later).with(file_set, file.id, filename)
      end
    end

    context 'when the characterization proxy content is absent' do
      before { allow(file_set).to receive(:characterization_proxy?).and_return(false) }

      it 'raises an error' do
        expect { described_class.perform_now(file_set, file.id) }.to raise_error(StandardError, /original_file was not found/)
      end
    end

    # I don't think we implement the Alpha channel storage
    # (at least )
    context 'when the file_set is an image' do
      let(:cmd_container) { double }
      let(:channel_value) { 'alpha value' }
      let(:characterization_proxy) { double(id: 'CharacterizationProxy', mime_type: 'application/none') }

      before do
        allow(Hyrax.config).to receive(:iiif_image_server?).and_return true
        allow(file_set).to receive(:image?).and_return true
        allow(file_set).to receive(:characterization_proxy).and_return characterization_proxy
        allow(characterization_proxy).to receive(:alpha_channels=)
        allow(characterization_proxy).to receive(:save!)
        allow(MiniMagick::Tool::Identify)
          .to receive(:new)
          .and_yield(cmd_container)
          .and_return(channel_value)

        allow(cmd_container).to receive(:format).with('%[channels]')
        allow(cmd_container).to receive(:<<).with(filename)
      end

      it 'parses and stores the alpha channels' do
        described_class.perform_now(file_set, file.id)

        expect(cmd_container).to have_received(:format).with('%[channels]')
        expect(cmd_container).to have_received(:<<).with(filename)

        expect(characterization_proxy).to have_received(:alpha_channels=).with([channel_value])
        expect(characterization_proxy).to have_received(:save!)
      end
    end
  end

  context 'when FITS_SERVLET_URL is defined' do
    before do
      stub_env('FITS_SERVLET_URL', 'http://localhost/fits')
    end

    let(:tool) { :fits_servlet }

    it_behaves_like 'the Hyrax CharacterizeJob'
  end

  context 'when no FITS_SERVLET_URL is defined' do
    before do
      stub_env('FITS_SERVLET_URL', nil)
    end

    let(:tool) { :fits }

    it_behaves_like 'the Hyrax CharacterizeJob'
  end
end
