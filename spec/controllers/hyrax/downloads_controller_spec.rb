# frozen_string_literal: true
#
# Tests the inclusion of {Spot::DownloadsControllerBehavior}, prepended to the class in spot_overrides.rb
#
# @see app/controllers/concerns/spot/downloads_controller_behavior.rb
# @see config/initializers/spot_overrides.rb
RSpec.describe Hyrax::DownloadsController do
  include ActiveJob::TestHelper

  routes { Hyrax::Engine.routes }

  let(:file_set) { create(:file_set, :public, content: File.open(original_file)) }
  let(:original_file) { Rails.root.join('spec', 'fixtures', 'image.png').to_s }
  let(:transcript_file) { Rails.root.join('spec', 'fixtures', 'image_transcript.vtt').to_s }

  before do
    perform_enqueued_jobs(only: IngestJob) do
      Spot::FileSetTranscriptAttachmentService.attach(path: transcript_file, file_set: file_set)
    end
  end

  describe 'downloading transcript' do
    it 'sends the file' do
      get :show, params: { id: file_set.id, file: 'transcript' }
      expect(response.body).to eq(File.read(transcript_file))
    end
  end
end