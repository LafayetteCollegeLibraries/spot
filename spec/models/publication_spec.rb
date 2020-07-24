# frozen_string_literal: true
describe Publication do
  it_behaves_like 'a model with hyrax core metadata'

  [
    [:subtitle, 'http://purl.org/spar/doco/Subtitle'],
    [:title_alternative, RDF::Vocab::DC.alternative],
    [:publisher, RDF::Vocab::DC11.publisher],
    [:source, RDF::Vocab::DC.source],
    [:resource_type, RDF::Vocab::DC.type],
    [:physical_medium, RDF::Vocab::DC.PhysicalMedium],
    [:language, RDF::Vocab::DC11.language],
    [:abstract, RDF::Vocab::DC.abstract],
    [:description, RDF::Vocab::DC11.description],
    [:note, RDF::Vocab::SKOS.note],
    [:identifier, RDF::Vocab::DC.identifier],
    [:bibliographic_citation, RDF::Vocab::DC.bibliographicCitation],
    [:date_issued, RDF::Vocab::DC.issued],
    [:date_available, RDF::Vocab::DC.available],
    [:creator, RDF::Vocab::DC11.creator],
    [:contributor, RDF::Vocab::DC11.contributor],
    [:editor, RDF::Vocab::BIBO.editor],
    [:academic_department, 'http://vivoweb.org/ontology/core#AcademicDepartment'],
    [:division, 'http://vivoweb.org/ontology/core#Division'],
    [:organization, 'http://vivoweb.org/ontology/core#Organization'],
    [:related_resource, RDF::RDFS.seeAlso],
    [:subject, RDF::Vocab::DC11.subject],
    [:keyword,  RDF::Vocab::SCHEMA.keywords],
    [:location, RDF::Vocab::DC.spatial],
    [:license, RDF::Vocab::DC.license],
    [:rights_statement, RDF::Vocab::EDM.rights],
    [:rights_holder, RDF::Vocab::DC.rightsHolder]
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
