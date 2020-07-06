# frozen_string_literal: true
describe Publication do
  let(:dc) { RDF::Vocab::DC }
  let(:dc11) { RDF::Vocab::DC11 }
  let(:bibo) { RDF::Vocab::BIBO }
  let(:rdfs) { RDF::RDFS }
  let(:schema) { RDF::Vocab::SCHEMA }
  let(:edm) { RDF::Vocab::EDM }
  let(:skos) { RDF::Vocab::SKOS }
  let(:subtitle_uri) { 'http://purl.org/spar/doco/Subtitle' }
  let(:dept_uri) { 'http://vivoweb.org/ontology/core#AcademicDepartment' }
  let(:division_uri) { 'http://vivoweb.org/ontology/core#Division' }
  let(:org_uri) { 'http://vivoweb.org/ontology/core#Organization' }

  it_behaves_like 'a model with hyrax core metadata'

  [
    [:subtitle, subtitle_uri],
    [:title_alternative, dc.alternative],
    [:publisher, dc11.publisher],
    [:source, dc.source],
    [:resource_type, dc.type],
    [:physical_medium, dc.PhysicalMedium],
    [:language, dc11.language],
    [:abstract, dc.abstract],
    [:description, dc11.description],
    [:note, skos.note],
    [:identifier, dc.identifier],
    [:bibliographic_citation, dc.bibliographicCitation],
    [:date_issued, dc.issued],
    [:date_available, dc.available],
    [:creator, dc11.creator],
    [:contributor, dc11.contributor],
    [:editor, bibo.editor],
    [:academic_department, dept_uri],
    [:division, division_uri],
    [:organization, org_uri],
    [:related_resource, rdfs.seeAlso],
    [:subject, dc11.subject],
    [:keyword, schema.keywords],
    [:location, dc.spatial],
    [:license, dc.license],
    [:rights_statement, edm.rights],
    [:rights_holder, dc.rightsHolder]
  ].each do |(prop, uri)|
    it { is_expected.to have_editable_property(prop).with_predicate(uri) }
  end

  describe 'validations' do
    let(:work) { build(:publication) }

    it_behaves_like 'it validates local authorities', field: :resource_type, authority: 'resource_types'
    it_behaves_like 'it validates local authorities', field: :rights_statement, authority: 'rights_statements'
    it_behaves_like 'it validates field presence', field: :title
    it_behaves_like 'it validates field presence', field: :resource_type, value: ['Article']
    it_behaves_like 'it validates field presence', field: :rights_statement
    it_behaves_like 'it ensures the existence of a NOID identifier'

    describe 'date_issued' do
      it 'can not be absent' do
        work.title = ['cool title'] # need this to validate
        work.date_issued = []

        expect(work.valid?).to be false
        expect(work.errors[:date_issued]).to include 'Date Issued may not be blank'
      end

      it 'can not be spelled out' do
        work.date_issued = ['September 21, 2019']

        expect(work.valid?).to be false
        expect(work.errors[:date_issued]).to include 'Date Issued must be in YYYY-MM-DD, YYYY-MM, or YYYY format'
      end

      it 'can not have multiple values' do
        work.date_issued = ['2019-09-21', '2019-11-19']

        expect(work.valid?).to be false
        expect(work.errors[:date_issued]).to include 'Date Issued may only contain one value'
      end

      it 'can be YYYY-MM-DD' do
        work.date_issued = ['2019-09-21']

        expect(work.valid?).to be true
      end

      it 'can be YYYY-MM' do
        work.date_issued = ['2019-09']

        expect(work.valid?).to be true
      end

      it 'can be YYYY' do
        work.date_issued = ['2019']

        expect(work.valid?).to be true
      end
    end

    describe 'rights_statement' do
      let(:uri) { 'http://creativecommons.org/publicdomain/mark/1.0/' }

      it 'can be an ActiveTriples::Resource' do
        work.rights_statement = [ActiveTriples::Resource.new(RDF::URI(uri))]
        expect(work.valid?).to be true
      end
    end
  end
end
