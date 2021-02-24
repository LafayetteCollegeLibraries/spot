# frozen_string_literal: true
RSpec.describe Hyrax::PublicationPresenter do
  subject(:presenter) { described_class.new(solr_doc, ability) }

  let(:solr_doc) { SolrDocument.new(solr_data) }
  let(:solr_data) { object.to_solr }
  let(:object) { build(:publication) }
  let(:ability) { Ability.new(build(:user)) }

  it_behaves_like 'a Spot presenter'
  it_behaves_like 'it humanizes date fields', for: %i[date_issued]
end
