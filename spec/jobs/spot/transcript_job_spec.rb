# frozen_string_literal: true
RSpec.describe Spot::TranscriptJob do
  let(:_file_set) { build(:file_set) }
  let(:file_set) { _file_set }
  let(:transcript_name) { "transcript.vtt" }
  let(:mock_download_service) { instance_double(Spot::TranscriptDownloadService) }

  before do
    allow(Spot::TranscriptDownloadService).to receive(:new).with(file_set: file_set, transcript_name: transcript_name).and_return(mock_download_service)
    allow(mock_download_service).to receive(:download_transcript)
  end

  it 'calls the TranscriptDownloadService' do
    described_class.perform_now(file_set: file_set, transcript_name: transcript_name)

    expect(mock_download_service).to have_received(:download_transcript)
  end
end