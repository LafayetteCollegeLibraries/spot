# frozen_string_literal: true
RSpec.describe AudioVisual do
  subject { described_class.new }

  it_behaves_like 'it includes Spot::WorkBehavior'

  # @todo might be useful to turn this into a shared_example?
  [
    [:date,                 RDF::Vocab::DC.date],
    [:date_associated,      'https://d-nb.info/standards/elementset/gnd#associatedDate'],
    [:inscription,          'http://dbpedia.org/ontology/inscription'],
    [:original_item_extent, RDF::Vocab::DC.extent],
    [:repository_location,  'http://purl.org/vra/placeOfRepository'],
    [:research_assistance,  'http://www.rdaregistry.info/Elements/a/#P50265'],
    [:barcode,              'https://schema.org/Barcode'],
    [:provenance,           RDF::Vocab::DC.provenance],
    [:premade_derivatives,  'http://ldr.lafayette.edu/ns#premade_derivatives'],
    [:stored_derivatives,   'http://ldr.lafayette.edu/ns#stored_derivatives']
  ].each do |(prop, uri)|
    it { is_expected.to have_editable_property(prop).with_predicate(uri) }
  end
end
