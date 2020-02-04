# frozen_string_literal: true
RSpec.describe Spot::Mappers::RjwStereoMapper do
  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  before { mapper.metadata = metadata }

  it_behaves_like 'a base EAIC mapper', skip_fields: [:description]

  describe '#date_associated' do
    subject { mapper.date_associated }

    let(:metadata) do
      { 'date.image.lower' => ['1921-01'], 'date.image.upper' => ['1932-02-11'] }
    end

    it { is_expected.to eq ['1921-01/1932-02-11'] }
  end

  describe '#description' do
    subject { mapper.description }

    let(:metadata) do
      {
        'description.critical' => ['It is fine but it could be better.'],
        'description.text.english' => ['Some English text describing the object.']
      }
    end

    let(:expected_results) do
      [
        RDF::Literal('It is fine but it could be better.', language: :en),
        RDF::Literal('Some English text describing the object.', language: :en)
      ]
    end

    it { is_expected.to eq expected_results }
  end

  describe '#keyword' do
    subject { mapper.keyword }

    let(:field) { 'relation.ispartof' }

    it_behaves_like 'a mapped field'
  end

  describe '#publisher' do
    subject { mapper.publisher }

    let(:field) { 'creator.company' }

    it_behaves_like 'a mapped field'
  end

  describe '#physical_medium' do
    subject { mapper.physical_medium }

    let(:field) { 'format.medium' }

    it_behaves_like 'a mapped field'
  end

  describe '#related_resource' do
    subject { mapper.related_resource }

    let(:field) { 'relation.seealso' }

    it_behaves_like 'a mapped field'
  end

  describe '#research_assistance' do
    subject { mapper.research_assistance }

    let(:field) { 'contributor' }

    it_behaves_like 'a mapped field'
  end

  describe '#subject_ocm' do
    subject { mapper.subject_ocm }

    let(:field) { 'subject.ocm' }

    it_behaves_like 'a mapped field'
  end
end
