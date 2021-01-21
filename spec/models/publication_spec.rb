# frozen_string_literal: true
RSpec.describe Publication do
  it_behaves_like 'it includes Spot::WorkBehavior'

  # @todo might be useful to turn this into a shared_example?
  [
    [:abstract,               RDF::Vocab::DC.abstract],
    [:academic_department,    'http://vivoweb.org/ontology/core#AcademicDepartment'],
    [:bibliographic_citation, RDF::Vocab::DC.bibliographicCitation],
    [:date_available,         RDF::Vocab::DC.available],
    [:date_issued,            RDF::Vocab::DC.issued],
    [:division,               'http://vivoweb.org/ontology/core#Division'],
    [:editor,                 RDF::Vocab::BIBO.editor],
    [:license,                RDF::Vocab::DC.license],
    [:organization,           'http://vivoweb.org/ontology/core#Organization']
  ].each do |(prop, uri)|
    it { is_expected.to have_editable_property(prop).with_predicate(uri) }
  end

  describe 'validations' do
    let(:work) { build(:publication) }

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
