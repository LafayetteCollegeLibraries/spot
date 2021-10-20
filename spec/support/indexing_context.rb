# frozen_string_literal: true
#
# Performs the grunt work of setting up mocks for indexing in a meta-y way
RSpec.shared_context 'indexing' do
  subject(:solr_doc) { indexer.generate_solr_document }

  let(:indexer) { described_class.new(work) }
  let(:work_klass) { described_class.name.gsub(/Indexer$/, '').underscore.to_sym }
  let(:work) { build(work_klass, **attributes) }
  let(:attributes) { {} }

  let(:file_set) { instance_double(FileSet, id: 'fs123def4') }
  let(:mime_type) { 'text/plain' }
  let(:thumbnail_path) { "/downloads/#{file_set.id}?file=thumbnail" }

  before do
    allow(work).to receive(:file_sets).and_return([file_set])
    allow(file_set).to receive(:mime_type).and_return(mime_type)
    allow(Hyrax::ThumbnailPathService).to receive(:call).with(work).and_return(thumbnail_path)

    stub_env('URL_HOST', 'localhost')
  end
end
