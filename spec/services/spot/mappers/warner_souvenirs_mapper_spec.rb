# frozen_string_literal: true
RSpec.describe Spot::Mappers::WarnerSouvenirsMapper do
  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  before { mapper.metadata = metadata }

  it_behaves_like 'a base EAIC mapper'

  describe '#date_scope_note' do
    subject { mapper.date_scope_note }

    let(:field) { 'description.indicia' }

    it_behaves_like 'a mapped field'
  end

  describe '#keyword' do
    subject { mapper.keyword }

    let(:field) { 'relation.ispartof' }

    it_behaves_like 'a mapped field'
  end

  describe '#language' do
    subject { mapper.language }

    let(:field) { 'language' }

    it_behaves_like 'a mapped field'
  end

  describe '#physical_medium' do
    subject { mapper.physical_medium }

    let(:field) { 'format.medium' }

    it_behaves_like 'a mapped field'
  end

  describe '#publisher' do
    subject { mapper.publisher }

    let(:field) { 'creator.company' }

    it_behaves_like 'a mapped field'
  end

  describe '#resource_type' do
    subject { mapper.resource_type }

    let(:field) { 'resource.type' }

    it_behaves_like 'a mapped field'
  end

  describe '#subject' do
    subject { mapper.subject }

    let(:metadata) { { 'subject' => ['http://id.worldcat.org/fast/1316662'] } }

    it { is_expected.to eq [RDF::URI('http://id.worldcat.org/fast/1316662')] }
  end

  describe '#subject_ocm' do
    subject { mapper.subject_ocm }

    let(:field) { 'subject.ocm' }

    it_behaves_like 'a mapped field'
  end
end
