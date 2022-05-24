# frozen_string_literal: true
RSpec.describe Qa::Authorities::SolrSuggest do
  subject(:authority) { described_class.new(dictionary) }

  let(:dictionary) { 'keyword' }
  let(:solr_field) { "#{dictionary}_sim" }

  describe '#search' do
    subject { authority.search('good') }

    before do
      objects.each { |obj| ActiveFedora::SolrService.add(obj) }
      ActiveFedora::SolrService.commit

      described_class.build_dictionaries!
    end

    let(:objects) { [obj1, obj2, obj3] }
    let(:obj1) { { id: 'obj1', solr_field => ['good to go'] } }
    let(:obj2) { { id: 'obj2', solr_field => ['nope not this one'] } }
    let(:obj3) { { id: 'obj3', solr_field => ['also good!'] } }

    let(:expected_results) do
      [obj1, obj3]
        .map { |t| t[solr_field].first }
        .map { |v| { id: v, label: v, value: v } }
    end

    [
      ['bibliographic_citation', 'bibliographic_citation_sim'],
      ['keyword', 'keyword_sim'],
      ['name', 'name_suggest_ssim'],
      ['organization', 'organization_sim'],
      ['physical_medium', 'physical_medium_sim'],
      ['publisher', 'publisher_sim'],
      ['source', 'source_sim']
    ].each do |dict, field|
      context "dictionary: #{dict}" do
        let(:dictionary) { dict }
        let(:solr_field) { field }

        it { is_expected.to include(*expected_results) }
      end
    end
  end

  describe '#term' do
    subject { authority.term('some_id') }

    it { is_expected.to eq({}) }
  end

  describe '#all' do
    subject { authority.all }

    it { is_expected.to eq [] }
  end

  describe '#build_dictionary!' do
    before do
      allow(ActiveFedora::SolrService.instance.conn)
        .to receive(:get)
        .with('/solr/spot-test/suggest', params: params)

      authority.build_dictionary!
    end

    context 'when acting on an individual field' do
      let(:dictionary) { 'keyword' }
      let(:params) { { 'suggest' => true, 'suggest.dictionary' => dictionary, 'suggest.build' => true }}

      it 'sends individaul dictionary params' do
        expect(ActiveFedora::SolrService.instance.conn)
          .to have_received(:get)
          .with('/solr/spot-test/suggest', params: params)
      end
    end

    context 'when building all' do
      let(:dictionary) { described_class::BUILD_ALL_KEYWORD }
      let(:params) { {'suggest' => true, 'suggest.buildAll' => true } }

      it 'sends the build_all params' do
        expect(ActiveFedora::SolrService.instance.conn)
          .to have_received(:get)
          .with('/solr/spot-test/suggest', params: params)
      end
    end
  end
end
