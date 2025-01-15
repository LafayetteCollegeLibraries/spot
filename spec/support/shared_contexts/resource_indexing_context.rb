# frozen_string_literal: true
RSpec.shared_context 'resource indexing' do
  subject(:indexer) { described_class.for(resource: resource) }

  let(:resource_factory) { described_class.name.split('::').last.gsub(/Indexer$/, '').underscore.to_sym }
  let(:resource) { build(resource_factory, **metadata) }
  let(:metadata) { {} }
  let(:solr_document) { indexer.to_solr }
end
