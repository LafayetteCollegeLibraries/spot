# frozen_string_literal: true
#
# Since this does some meta-programming to determine the factory to use,
# it's best to call this from within a specific Indexer spec.
#
# @example invoking the shared spec
#   RSpec.describe PublicationIndexer do
#     # ...
#
#     it_behaves_like 'it indexes a sortable date'
#   end
RSpec.shared_examples 'it indexes a sortable date' do
  subject(:date_sort) { solr_doc['date_issued_sort_dtsi'] }

  let(:solr_doc) { indexer.generate_solr_document }

  # mEtA-pRoGrAmMiNg
  let(:work_klass) { described_class.name.gsub(/Indexer$/, '').downcase.to_sym }
  let(:work) { build(work_klass, date_issued: example_date, create_date: '2019-01-01T12:34:56Z') }

  context 'when date_issued is YYYY' do
    let(:example_date) { ['2019'] }

    it { is_expected.to eq '2019-01-01T00:00:00Z' }
  end

  context 'when date_issued is YYYY-MM' do
    let(:example_date) { ['2019-05'] }

    it { is_expected.to eq '2019-05-01T00:00:00Z' }
  end

  context 'when date_issued is YYYY-MM-DD' do
    let(:example_date) { ['2019-05-07'] }

    it { is_expected.to eq '2019-05-07T00:00:00Z' }
  end

  context 'when date_issued is empty' do
    let(:example_date) { [] }

    it { is_expected.to eq work.create_date }
  end

  context 'when date_issued contains multiple values' do
    let(:example_date) { ['2019-05-07', '1991-09-04'] }

    it 'uses the earlier date' do
      expect(date_sort).to eq '1991-09-04T00:00:00Z'
    end
  end
end
