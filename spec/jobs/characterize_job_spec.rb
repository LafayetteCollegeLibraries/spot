# frozen_string_literal: true
#
# Most of this is copied from the Hyrax source (https://github.com/samvera/hyrax/blob/e1de3d4/spec/jobs/characterize_job_spec.rb)
# but is updated to:
#   - include a spec for our service switching
#   - use instance_doubles rather than the Hyrax factories
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
    allow(Hydra::Works::CharacterizationService).to receive(:run).with(file, filename)
    allow(CreateDerivativesJob).to receive(:perform_later).with(file_set, file.id, filename)
  end

  context 'when FITS_SERVLET_URL is defined' do
    before do
      allow(Spot::RemoteCharacterizationService).to receive(:run).with(file, filename)

      # some ~gross~ stubbing
      allow(ENV).to receive(:include?).and_call_original
      allow(ENV).to receive(:include?).with('FITS_SERVLET_URL').and_return true

      described_class.perform_now(file_set, file.id, filename)
    end

    it 'does not call the hydra-works characterization service' do
      expect(Hydra::Works::CharacterizationService).not_to have_received(:run).with(file, filename)
    end

    it 'calls Spot::RemoteCharacterizationService instead' do
      expect(Spot::RemoteCharacterizationService).to have_received(:run).with(file, filename)
    end
  end

  context 'with valid filepath param' do
    let(:filename) { Rails.root.join('spec', 'fixtures', 'image.png') }

    before do
      allow(Hyrax::WorkingDirectory).to receive(:find_or_retrieve)

      described_class.perform_now(file_set, file.id, filename)
    end

    it 'skips Hyrax::WorkingDirectory' do
      expect(Hyrax::WorkingDirectory).not_to have_received(:find_or_retrieve)
      expect(Hydra::Works::CharacterizationService).to have_received(:run).with(file, filename)
    end
  end

  context 'when the characterization proxy content is present' do
    before { described_class.perform_now(file_set, file.id) }

    it 'runs Hydra::Works::CharacterizationService and creates a CreateDerivativesJob' do
      expect(Hydra::Works::CharacterizationService).to have_received(:run).with(file, filename)
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

  context "when the file set's work is in a collection" do
    let(:work)       { instance_double(Publication, in_collections: [collection]) }
    let(:collection) { instance_double(Collection, update_index: true) }

    before do
      allow(file_set).to receive(:parent).and_return(work)
      described_class.perform_now(file_set, file.id)
    end

    it "reindexes the collection" do
      expect(collection).to have_received(:update_index)
    end
  end
end
