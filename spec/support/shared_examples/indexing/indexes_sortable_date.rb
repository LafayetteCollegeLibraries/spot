# frozen_string_literal: true
RSpec.shared_examples 'it indexes a sortable date' do
  subject { solr_doc['date_sort_dtsi'] }

  let(:solr_doc) { indexer.generate_solr_document }
  let(:indexer) { described_class.new(work) }
  let(:work) { build(work_klass, id: 'abc123def', sortable_date_property => date_values) }
  let(:work_klass) { described_class.name.gsub(/Indexer$/, '').underscore.to_sym }

  let(:sortable_date_property) { described_class.sortable_date_property }
  let(:date_values) { ['2020-06-08'] }

  it { is_expected.to eq '2020-06-08T00:00:00Z' }

  context 'when an EDTF list' do
    let(:date_values) { ['{1986,1991,2020}'] }

    it { is_expected.to eq '1986-01-01T00:00:00Z' }
  end

  context 'when a choice EDTF list' do
    let(:date_values) { ['[1986,1991]'] }

    it { is_expected.to eq '1986-01-01T00:00:00Z' }
  end

  context 'when an EDTF interval' do
    let(:date_values) { ['1986-02/2020-06'] }

    it { is_expected.to eq '1986-02-01T00:00:00Z' }
  end
end
