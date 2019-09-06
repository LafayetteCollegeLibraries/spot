# frozen_string_literal: true
RSpec.shared_examples 'it indexes a permalink' do
  subject(:solr_doc) { indexer.generate_solr_document }

  let(:indexer) { described_class.new(work) }
  let(:work_klass) { described_class.name.gsub(/Indexer$/, '').downcase.to_sym }
  let(:work) { build(work_klass, id: 'abc123def', identifier: identifier) }
  let(:solr_field) { described_class::PERMALINK_SOLR_FIELD }

  context 'when no identifiers present' do
    let(:identifier) { [] }

    it { is_expected.not_to include(solr_field) }
  end

  context 'when no handle identifiers present' do
    let(:identifier) { ['issn:1234-5678'] }

    it { is_expected.not_to include(solr_field) }
  end

  context 'when one handle identifier is present' do
    let(:identifier) { %w[issn:1234-5678 hdl:10385/1234] }

    it 'is a handle.net URI to the ID' do
      expect(solr_doc[solr_field]).to eq 'http://hdl.handle.net/10385/1234'
    end
  end

  context 'when more than one handle identifier is present' do
    let(:identifier) { %w[hdl:10385/1234 hdl:10385/abc123def issn:1234-5678] }

    it 'prefers the URI that includes the work.id value' do
      expect(solr_doc[solr_field]).to eq "http://hdl.handle.net/10385/abc123def"
    end
  end

  context 'when none of the identifiers contain the noid' do
    let(:identifier) { %w[hdl:10385/1234 hdl:10385/5678 issn:1234-5678] }
    let(:candidates) do
      %w[http://hdl.handle.net/10385/1234 http://hdl.handle.net/10385/5678]
    end

    it 'uses the one of the handle identifiers' do
      expect(candidates).to include(solr_doc[solr_field])
    end
  end
end
