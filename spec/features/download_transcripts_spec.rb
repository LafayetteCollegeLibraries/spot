# frozen_string_literal: true
RSpec.describe 'Hyrax::DownloadsController' do
  let(:file_set) { FileSet.create(visibility: 'open') }
  let(:original_file) { Rails.root.join('spec/fixtures/image.png') }
  let(:transcript_file) { Rails.root.join('spec/fixtures/image_transcript.vtt') }

  before do
    Hydra::Works::AddFileToFileSet.call(file_set, File.open(transcript_file), :transcript)
  end

  after do
    file_set.destroy!
  end

  scenario 'downloading transcript' do
    visit "/downloads/#{file_set.id}?file=transcript"
    expect(page.body).to eq(File.read(transcript_file))
  end
end