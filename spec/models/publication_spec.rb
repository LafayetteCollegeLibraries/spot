# frozen_string_literal: true
describe Publication do
  subject(:pub) { described_class.new }

  let(:dc) { RDF::Vocab::DC }
  let(:dc11) { RDF::Vocab::DC11 }
  let(:bibo) { RDF::Vocab::BIBO }
  let(:rdfs) { RDF::RDFS }
  let(:schema) { RDF::Vocab::SCHEMA }
  let(:edm) { RDF::Vocab::EDM }
  let(:subtitle_uri) { 'http://purl.org/spar/doco/Subtitle' }
  let(:dept_uri) { 'http://vivoweb.org/ontology/core#AcademicDepartment' }
  let(:division_uri) { 'http://vivoweb.org/ontology/core#Division' }
  let(:org_uri) { 'http://vivoweb.org/ontology/core#Organization' }

  it_behaves_like 'a model with hyrax core metadata'

  it { is_expected.to have_editable_property(:subtitle).with_predicate(subtitle_uri) }
  it { is_expected.to have_editable_property(:title_alternative).with_predicate(dc.alternative) }
  it { is_expected.to have_editable_property(:publisher).with_predicate(dc11.publisher) }
  it { is_expected.to have_editable_property(:source).with_predicate(dc.source) }
  it { is_expected.to have_editable_property(:resource_type).with_predicate(dc.type) }
  it { is_expected.to have_editable_property(:physical_medium).with_predicate(dc.PhysicalMedium) }
  it { is_expected.to have_editable_property(:language).with_predicate(dc11.language) }
  it { is_expected.to have_editable_property(:abstract).with_predicate(dc.abstract) }
  it { is_expected.to have_editable_property(:description).with_predicate(dc11.description) }
  it { is_expected.to have_editable_property(:identifier).with_predicate(dc.identifier) }
  it { is_expected.to have_editable_property(:bibliographic_citation).with_predicate(dc.bibliographicCitation) }
  it { is_expected.to have_editable_property(:date_issued).with_predicate(dc.issued) }
  it { is_expected.to have_editable_property(:date_available).with_predicate(dc.available) }
  it { is_expected.to have_editable_property(:creator).with_predicate(dc11.creator) }
  it { is_expected.to have_editable_property(:contributor).with_predicate(dc11.contributor) }
  it { is_expected.to have_editable_property(:editor).with_predicate(bibo.editor) }
  it { is_expected.to have_editable_property(:academic_department).with_predicate(dept_uri) }
  it { is_expected.to have_editable_property(:division).with_predicate(division_uri) }
  it { is_expected.to have_editable_property(:organization).with_predicate(org_uri) }
  it { is_expected.to have_editable_property(:related_resource).with_predicate(rdfs.seeAlso) }
  it { is_expected.to have_editable_property(:subject).with_predicate(dc11.subject) }
  it { is_expected.to have_editable_property(:keyword).with_predicate(schema.keywords) }
  it { is_expected.to have_editable_property(:based_near).with_predicate(dc.spatial) }
  it { is_expected.to have_editable_property(:license).with_predicate(dc.license) }
  it { is_expected.to have_editable_property(:rights_statement).with_predicate(edm.rights) }
end
