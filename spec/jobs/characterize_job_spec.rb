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

  before do
    allow(FileSet).to receive(:find).with(file_set_id).and_return(file_set)
    allow(Hydra::Works::CharacterizationService).to receive(:run).with(file, filename, ch12n_tool: tool)
    allow(CreateDerivativesJob).to receive(:perform_later).with(file_set, file.id, filename)
    allow(Hyrax::WorkingDirectory).to receive(:find_or_retrieve).and_return(filename)
  end

  shared_examples 'the Hyrax CharacterizeJob' do
    context 'with valid filepath param' do
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
