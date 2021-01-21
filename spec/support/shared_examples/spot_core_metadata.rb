# frozen_string_literal: true
RSpec.shared_examples 'it includes Spot::CoreMetadata' do
  subject { described_class.new }

  [
    [:contributor,       RDF::Vocab::DC11.contributor],
    [:creator,           RDF::Vocab::DC11.creator],
    [:description,       RDF::Vocab::DC11.description],
    [:identifier,        RDF::Vocab::DC.identifier],
    [:keyword,           RDF::Vocab::SCHEMA.keywords],
    [:language,          RDF::Vocab::DC11.language],
    [:location,          RDF::Vocab::DC.spatial],
    [:note,              RDF::Vocab::SKOS.note],
    [:physical_medium,   RDF::Vocab::DC.PhysicalMedium],
    [:publisher,         RDF::Vocab::DC11.publisher],
    [:related_resource,  RDF::RDFS.seeAlso],
    [:resource_type,     RDF::Vocab::DC.type],
    [:rights_holder,     RDF::Vocab::DC.rightsHolder],
    [:rights_statement,  RDF::Vocab::EDM.rights],
    [:source,            RDF::Vocab::DC.source],
    [:subject,           RDF::Vocab::DC11.subject],
    [:subtitle,          RDF::URI.new('http://purl.org/spar/doco/Subtitle')],
    [:title_alternative, RDF::Vocab::DC.alternative]
  ].each do |(property, predicate)|
    it { is_expected.to have_editable_property(property).with_predicate(predicate) }
  end
end
