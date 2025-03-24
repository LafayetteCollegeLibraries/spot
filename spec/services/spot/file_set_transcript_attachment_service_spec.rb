# frozen_string_literal: true
RSpec.describe 'Spot::FileSetTranscriptAttachmentService' do
  include ActiveJob::TestHelper

  let(:file_set) { create(:file_set, content: File.open(original_file_path)) }
  let(:original_file_path) { Rails.root.join('spec', 'fixtures', 'document.pdf').to_s }
  let(:transcript_path) { Rails.root.join('spec', 'fixtures', 'image_transcript.vtt').to_s }

  it 'attaches a transcript file' do
    perform_enqueued_jobs(only: IngestJob) do
      expect(file_set.transcript).to be nil
      Spot::FileSetTranscriptAttachmentService.attach(path: transcript_path, file_set: file_set)

      file_set.reload
      expect(file_set.transcript).to be_a(Hydra::PCDM::File)
    end
  end
end
