# frozen_string_literal: true
RSpec.describe Image do
  subject { described_class.new }

  it_behaves_like 'a model with hyrax core metadata'

  [
    [:subtitle, 'http://purl.org/spar/doco/Subtitle'],
    [:title_alternative, RDF::Vocab::DC.alternative],
    [:publisher, RDF::Vocab::DC11.publisher],
    [:repository_location, 'http://purl.org/vra/placeOfRepository'],
    [:source, RDF::Vocab::DC.source],
    [:resource_type, RDF::Vocab::DC.type],
    [:physical_medium, RDF::Vocab::DC.PhysicalMedium],
    [:original_item_extent, RDF::Vocab::DC.extent],
    [:language, RDF::Vocab::DC11.language],
    [:description, RDF::Vocab::DC11.description],
    [:inscription, 'http://dbpedia.org/ontology/inscription'],
    [:date, RDF::Vocab::DC.date],
    [:date_scope_note, RDF::Vocab::SKOS.scopeNote],
    [:date_associated, 'https://d-nb.info/standards/elementset/gnd#associatedDate'],
    [:creator, RDF::Vocab::DC11.creator],
    [:contributor, RDF::Vocab::DC11.contributor],
    [:related_resource, RDF::RDFS.seeAlso],
    [:subject, RDF::Vocab::DC11.subject],
    [:subject_ocm, 'https://hraf.yale.edu/resources/reference/outline-of-cultural-materials'],
    [:keyword, RDF::Vocab::SCHEMA.keywords],
    [:location, RDF::Vocab::DC.spatial],
    [:rights_statement, RDF::Vocab::EDM.rights],
    [:rights_holder, RDF::Vocab::DC.rightsHolder],
    [:identifier, RDF::Vocab::DC.identifier],
    [:requested_by, 'http://rdf.myexperiment.org/ontologies/base/has-requester'],
    [:research_assistance, 'http://www.rdaregistry.info/Elements/a/#P50265'],
    [:donor, RDF::Vocab::DC.provenance],
    [:note, RDF::Vocab::SKOS.note]
  ].each do |(prop, uri)|
    it { is_expected.to have_editable_property(prop).with_predicate(uri) }
  end

  describe 'validations' do
    it_behaves_like 'it validates field presence', field: :title
    it_behaves_like 'it validates field presence', field: :resource_type, value: ['Image']
    it_behaves_like 'it validates field presence', field: :rights_statement
    it_behaves_like 'it validates local authorities', field: :resource_type, authority: 'resource_types'
    it_behaves_like 'it validates local authorities', field: :rights_statement, authority: 'rights_statements'
    it_behaves_like 'it ensures the existence of a NOID identifier'
  end
end
