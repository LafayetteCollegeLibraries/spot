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

    it { is_expected.to eq expected_results }
  end

  describe '#term' do
    subject { authority.term('some_id') }

    it { is_expected.to eq({}) }
  end

  describe '#all' do
    subject { authority.all }

    it { is_expected.to eq [] }
  end
end
