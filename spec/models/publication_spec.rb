# frozen_string_literal: true
describe Publication do
  subject(:pub) { described_class.new }

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

  it { is_expected.to have_editable_property(:subtitle).with_predicate(subtitle_uri) }
  it { is_expected.to have_editable_property(:title_alternative).with_predicate(dc.alternative) }
  it { is_expected.to have_editable_property(:publisher).with_predicate(dc11.publisher) }
  it { is_expected.to have_editable_property(:source).with_predicate(dc.source) }
  it { is_expected.to have_editable_property(:resource_type).with_predicate(dc.type) }
  it { is_expected.to have_editable_property(:physical_medium).with_predicate(dc.PhysicalMedium) }
  it { is_expected.to have_editable_property(:language).with_predicate(dc11.language) }
  it { is_expected.to have_editable_property(:abstract).with_predicate(dc.abstract) }
  it { is_expected.to have_editable_property(:description).with_predicate(dc11.description) }
  it { is_expected.to have_editable_property(:note).with_predicate(skos.note) }
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
  it { is_expected.to have_editable_property(:location).with_predicate(dc.spatial) }
  it { is_expected.to have_editable_property(:license).with_predicate(dc.license) }
  it { is_expected.to have_editable_property(:rights_statement).with_predicate(edm.rights) }
  it { is_expected.to have_editable_property(:rights_holder).with_predicate(dc.rightsHolder) }

  describe 'validations' do
    let(:work) { build(:publication) }

    it_behaves_like 'it ensures the existence of a NOID identifier'

    describe 'title' do
      it 'must be present' do
        work.title = []

        expect(work.valid?).to be false
        expect(work.errors[:title]).to include 'Your work must include a Title.'

        work.title = ['A cool title']

        expect(work.valid?).to be true
      end
    end

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
    end

    it 'can be YYYY' do
      work.date_issued = ['2019']

      expect(work.valid?).to be true
    end

    describe 'rights_statement' do
      it 'must be present' do
        work.rights_statement = []

        expect(work.valid?).to be false
        expect(work.errors[:rights_statement]).to include 'Your work must include a Rights Statement.'

        work.rights_statement = ['http://creativecommons.org/worklicdomain/mark/1.0/']
        expect(work.valid?).to be true
      end
    end

    describe 'resource_type' do
      it 'must be present' do
        work.resource_type = []

        expect(work.valid?).to be false
        expect(work.errors[:resource_type]).to include 'Your work must include a Resource Type.'

        work.resource_type = ['Article']
        expect(work.valid?).to be true
      end

      it 'must be included in the authority' do
        work.resource_type = ['A noise tape']

        expect(work.valid?).to be false
        expect(work.errors[:resource_type]).to include '"A noise tape" is not a valid Resource Type.'
      end
    end
  end
end
