# frozen_string_literal: true
RSpec.shared_examples 'it exports image derivatives' do
  subject(:derivative_options) { presenter.image_derivative_options }

  let(:presenter) { described_class.new(solr_doc, ability, nil) }
  let(:solr_document) { SolrDocument.new(work.to_solr) }
  let(:work) { build(work_klass.underscore.to_sym, id: 'work-id') }
  let(:work_klass) { described_class.name.split('::').last.gsub(/Presenter$/, '') }
  let(:url_builder) { ->(size, label) { "#{ENV['IIIF_BASE_URL']}/representative/full/#{size}/0/default.jpg?response-content-disposition=attachment%3B%20work-id-#{label}.jpg" } }

  before do
    allow(presenter).to receive(:representative_id).and_return('representative')
    allow(presenter).to receive(:id).and_return(work.id)
  end

  it 'returns an array of labels and iiif urls' do
    expect(derivative_options).to eq [
      ['Full Size', url_builder.call('full', 'full')], ['Large (1200px)', url_builder.call('!1200,1200', 'large')],
      ['Medium (900px)', url_builder.call('!900,900', 'medium')], ['Small (600px)', url_builder.call('!600,600', 'small')]
    ]
  end
end
