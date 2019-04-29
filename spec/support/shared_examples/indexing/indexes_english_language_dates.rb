# frozen_string_literal: true
RSpec.shared_examples 'it indexes English-language dates' do
  subject(:solr_doc) { indexer.generate_solr_document }

  let(:indexer) { described_class.new(work) }
  let(:work_klass) { described_class.name.gsub(/Indexer$/, '').downcase.to_sym }
  let(:work) { build(work_klass) }
  let(:date) { '2019-02-08T00:00:00Z' }
  let(:field_name) { described_class.english_language_date_field }
  let(:date_field) { described_class.date_property_for_english_language_indexing }

  before do
    work.send(:"#{date_field}=", [date])
  end

  it { is_expected.to include field_name }

  describe 'the date field' do
    subject { solr_doc[field_name] }

    [
      nil,
      ['January 2019', 'Jan 2019', 'Winter 2019'],
      ['February 2019', 'Feb 2019', 'Winter 2019'],
      ['March 2019', 'Mar 2019', 'Spring 2019'],
      ['April 2019', 'Apr 2019', 'Spring 2019'],
      ['May 2019', 'May 2019', 'Spring 2019'],
      ['June 2019', 'Jun 2019', 'Summer 2019'],
      ['July 2019', 'Jul 2019', 'Summer 2019'],
      ['August 2019', 'Aug 2019', 'Summer 2019'],
      ['September 2019', 'Sep 2019', 'Fall 2019', 'Autumn 2019'],
      ['October 2019', 'Oct 2019', 'Fall 2019', 'Autumn 2019'],
      ['November 2019', 'Nov 2019', 'Fall 2019', 'Autumn 2019'],
      ['December 2019', 'Dec 2019', 'Winter 2019']
    ].each_with_index do |values, idx|
      next if values.nil?

      context do
        let(:date) { Date.new(2019, idx, 8).strftime('%Y-%m-%d') }

        it { is_expected.to include(*values) }
      end
    end

    context 'when the year is YYYY-MM' do
      let(:date) { '2019-02' }
      let(:expected_values) { ['February 2019', 'Feb 2019', 'Winter 2019'] }

      it { is_expected.to include(*expected_values) }
    end

    context 'when only YYYY' do
      let(:date) { '2019' }

      it { is_expected.to be_empty }
    end
  end
end
