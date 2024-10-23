# frozen_string_literal: true
RSpec.describe 'Hyrax::DownloadsController' do
  include ActiveJob::TestHelper

  let(:file_set) { create(:file_set, :public, content: File.open(original_file)) }
  let(:original_file) { Rails.root.join('spec', 'fixtures', 'image.png').to_s }
  let(:transcript_file) { Rails.root.join('spec', 'fixtures', 'image_transcript.vtt').to_s }

  before do
    perform_enqueued_jobs(only: IngestJob) do
      Spot::FileSetTranscriptAttachmentService.attach(path: transcript_file, file_set: file_set)
    end
  end

  scenario 'downloading transcript' do
    visit "/downloads/#{file_set.id}?file=transcript"
    expect(page.body).to eq(File.read(transcript_file))
  end
end
