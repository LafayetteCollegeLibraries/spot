# frozen_string_literal: true
require 'hydra/file_characterization'
require 'hydra/file_characterization/characterizers/fits_servlet'

RSpec.describe Spot::CharacterizationService do
  subject(:perform_service) { described_class.perform(file_set, pcdm_file.id) }

  before do
    allow(Hydra::FileCharacterization::Characterizers::Fits)
      .to receive(:new)
      .and_return(fits_mock)

    allow(Hydra::FileCharacterization::Characterizers::FitsServlet)
      .to receive(:new)
      .and_return(fits_servlet_mock)

    allow(Hyrax::WorkingDirectory)
      .to receive(:find_or_retrieve)
      .with(pcdm_file.id, file_set.id)
      .and_return(file_path)

    allow(file_set).to receive(:update_index)
    allow(file_set).to receive(:parent).and_return(nil)

    perform_service
  end

  after do
    pcdm_file.delete
  end

  let(:fits_mock) { instance_double(Hydra::FileCharacterization::Characterizers::Fits, call: fits_xml_response) }
  let(:fits_servlet_mock) { instance_double(Hydra::FileCharacterization::Characterizers::FitsServlet, call: fits_xml_response) }
  let(:fits_xml_response) do
    <<-END
    <?xml version=\"1.0\" encoding=\"UTF-8\"?>
    <fits>
      <metadata>
        <document>
          <author>Microsoft\xAE Word 2010</author>
        </document>
      </metadata>
    </fits>
    END
  end

  let(:pcdm_file) do
    Hydra::PCDM::File.new.tap { |file| file.content = 'cool beans' }
  end

  let(:file_set) { instance_double(FileSet, id: 'fs1', files: [pcdm_file], characterization_proxy: pcdm_file) }
  let(:file_path) { Rails.root.join('spec', 'fixtures', 'document.pdf').to_s }

  it 'adds cleaned up values to the file object' do
    expect(pcdm_file.creator).to eq ["Microsoft� Word 2010"]
    expect(pcdm_file.creator).not_to eq ["Microsoft\xAE Word 2010"]
  end

  describe 'determining tool via ENV variable' do
    context 'when FITS_SERVLET_URL is not defined' do
      before { stub_env('FITS_SERVLET_URL', nil) }

      it 'calls the local fits service' do
        expect(fits_mock).to have_received(:call).exactly(1).time
        expect(fits_servlet_mock).not_to have_received(:call)
      end
    end
  end
end
