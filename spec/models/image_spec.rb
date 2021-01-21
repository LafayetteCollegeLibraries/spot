# frozen_string_literal: true
RSpec.describe Image do
  subject { described_class.new }

  it_behaves_like 'a model with hyrax core metadata'

  # @todo might be useful to turn this into a shared_example?
  [
    [:date,                 RDF::Vocab::DC.date],
    [:date_scope_note,      RDF::Vocab::SKOS.scopeNote],
    [:date_associated,      'https://d-nb.info/standards/elementset/gnd#associatedDate'],
    [:donor,                RDF::Vocab::DC.provenance],
    [:inscription,          'http://dbpedia.org/ontology/inscription'],
    [:original_item_extent, RDF::Vocab::DC.extent],
    [:repository_location,  'http://purl.org/vra/placeOfRepository'],
    [:requested_by,         'http://rdf.myexperiment.org/ontologies/base/has-requester'],
    [:research_assistance,  'http://www.rdaregistry.info/Elements/a/#P50265'],
    [:subject_ocm,          'https://hraf.yale.edu/resources/reference/outline-of-cultural-materials']
  ].each do |(prop, uri)|
    it { is_expected.to have_editable_property(prop).with_predicate(uri) }
  end
end
