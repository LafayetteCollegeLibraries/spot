# frozen_string_literal: true
RSpec.shared_examples 'a Solr suggestion authority' do
  subject(:authority) { described_class.new }

  describe 'the .suggestion_dictionary class_attribute' do
    subject { described_class.suggestion_dictionary }

    it { is_expected.not_to be nil }
  end

  describe '#search' do
    subject { authority.search('good') }

    before do
      objects.each { |obj| ActiveFedora::SolrService.add(obj) }
      ActiveFedora::SolrService.commit

      described_class.build_dictionary!
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
end

# Turning these into shared examples, rather than as part of the
# above example, in the event that we decide to build out these methods
# for one or all of the suggestion authorities

RSpec.shared_examples 'it no-ops #term' do
  describe '#term' do
    subject { described_class.new.term('some_id') }

    it { is_expected.to eq({}) }
  end
end

RSpec.shared_examples 'it no-ops #all' do
  describe '#all' do
    subject { described_class.new.all }

    it { is_expected.to eq [] }
  end
end
