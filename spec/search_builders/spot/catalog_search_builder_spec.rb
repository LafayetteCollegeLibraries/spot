# frozen_string_literal: true
RSpec.describe Spot::CatalogSearchBuilder do
  subject(:builder) { described_class.new([], scope).with(blacklight_params) }

  let(:scope) { OpenStruct.new(blacklight_config: CatalogController.blacklight_config) }
  let(:blacklight_parameters) { params }
  let(:params) { { search_field: 'advanced' } }
  let(:solr_parameters) { {} }

  describe '#add_advanced_search_to_solr' do
    before { builder.add_advanced_search_to_solr(solr_parameters) }

    let(:blacklight_params) { params.merge(title: 'a cool query AND thing') }

    context 'when the only query to exist' do
      it 'adds the value as _query_' do
        expect(solr_parameters[:q].scan(/_query_:/).size).to eq 1
      end
    end

    context 'when another query already exists' do
      let(:solr_parameters) { { q: '_query_:"{!dismax title_tesim}first-search"'} }

      it 'appends another _query_ value' do
        expect(solr_parameters[:q].scan(/_query_/).size).to eq 2
      end
    end
  end

  describe 'show_works_or_works_that_contain_files' do
    before { builder.show_works_or_works_that_contain_files(solr_parameters) }

    let(:blacklight_params) { params.merge(q: 'a good search') }

    context 'when the only query to exist' do
      it 'moves blacklight_params[:q] to :user_query' do
        expect(solr_parameters[:user_query]).to eq blacklight_params[:q]
      end

      it 'adds the {!lucene}_query_ syntax to solr_parameters[:q]' do
        expect(solr_parameters[:q]).to include '_query_'
        expect(solr_parameters[:q]).to include '$user_query'
      end
    end

    context 'when another query already exists' do
      let(:solr_parameters) { { q: '_query_:cool+beans' } }

      it 'appends the pre-existing value' do
        expect(solr_parameters[:q]).to include '_query_:cool+beans'
      end
    end
  end
end
