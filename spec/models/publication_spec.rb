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
    let(:pub) { build(:publication) }

    # rubocop:disable RSpec/ExampleLength
    describe '#ensure_noid_in_identifier callback' do
      let(:attributes) do
        { title: ['a good work'], date_issued: ['2019-11'],
          resource_type: ['Article'], rights_statement: ['http://creativecommons.org/publicdomain/mark/1.0/'] }
      end

      it 'inserts "noid:<id>" before save when an ID is present' do
        pub = described_class.new(attributes)
        pub.save

        noid_id = "noid:#{pub.id}"

        # it's a new record
        expect(pub.identifier).not_to include noid_id

        pub.identifier = ['abc:123']
        pub.save

        # adds the noid:<id>
        expect(pub.identifier).to contain_exactly 'abc:123', noid_id

        pub.identifier = []
        pub.save

        expect(pub.identifier).to contain_exactly noid_id
        pub.destroy!
      end
    end

    describe 'title' do
      it 'must be present' do
        pub.title = []

        expect(pub.valid?).to be false
        expect(pub.errors[:title]).to include 'Your work must include a Title.'

        pub.title = ['A cool title']

        expect(pub.valid?).to be true
      end
    end

    describe 'date_issued' do
      it 'can not be absent' do
        pub.title = ['cool title'] # need this to validate
        pub.date_issued = []

        expect(pub.valid?).to be false
        expect(pub.errors[:date_issued]).to include 'Date Issued may not be blank'
      end

      it 'can not be spelled out' do
        pub.date_issued = ['September 21, 2019']

        expect(pub.valid?).to be false
        expect(pub.errors[:date_issued]).to include 'Date Issued must be in YYYY-MM-DD or YYYY-MM format'
      end

      it 'can not have multiple values' do
        pub.date_issued = ['2019-09-21', '2019-11-19']

        expect(pub.valid?).to be false
        expect(pub.errors[:date_issued]).to include 'Date Issued may only contain one value'
      end

      it 'can be YYYY-MM-DD' do
        pub.date_issued = ['2019-09-21']

        expect(pub.valid?).to be true
      end

      it 'can be YYYY-MM' do
        pub.date_issued = ['2019-09']

        expect(pub.valid?).to be true
      end
    end

    it 'can be YYYY' do
      pub.date_issued = ['2019']

      expect(pub.valid?).to be true
    end

    describe 'rights_statement' do
      it 'must be present' do
        pub.rights_statement = []

        expect(pub.valid?).to be false
        expect(pub.errors[:rights_statement]).to include 'Your work must include a Rights Statement.'

        pub.rights_statement = ['http://creativecommons.org/publicdomain/mark/1.0/']
        expect(pub.valid?).to be true
      end
    end

    describe 'resource_type' do
      it 'must be present' do
        pub.resource_type = []

        expect(pub.valid?).to be false
        expect(pub.errors[:resource_type]).to include 'Your work must include a Resource Type.'

        pub.resource_type = ['Article']
        expect(pub.valid?).to be true
      end

      it 'must be included in the authority' do
        pub.resource_type = ['A noise tape']

        expect(pub.valid?).to be false
        expect(pub.errors[:resource_type]).to include '"A noise tape" is not a valid Resource Type.'
      end
    end
  end
end
