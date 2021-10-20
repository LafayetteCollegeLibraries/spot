# frozen_string_literal: true
RSpec.describe StudentWork do
  subject { described_class.new }

  it_behaves_like 'it includes Spot::WorkBehavior'

  [
    [:abstract,               RDF::Vocab::DC.abstract],
    [:access_note,            RDF::Vocab::DC.accessRights],
    [:advisor,                'http://id.loc.gov/vocabulary/relators/ths'],
    [:bibliographic_citation, RDF::Vocab::DC.bibliographicCitation],
    [:date,                   RDF::Vocab::DC.date],
    [:date_available,         RDF::Vocab::DC.available]
  ].each do |(prop, uri)|
    it { is_expected.to have_editable_property(prop).with_predicate(uri) }
  end
end
