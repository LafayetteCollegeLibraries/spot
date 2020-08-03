# frozen_string_literal: true
RSpec.describe Spot::Mappers::TjwarPostcardsMapper do
  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  before { mapper.metadata = metadata }

  it_behaves_like 'a base EAIC mapper'

  describe '#date_scope_note' do
    subject { mapper.date_scope_note }

    let(:field) { 'description.indicia' }

    it_behaves_like 'a mapped field'
  end

  describe '#donor' do
    subject { mapper.donor }

    let(:field) { 'contributor.donor' }

    it_behaves_like 'a mapped field'
  end

  describe '#keyword' do
    subject { mapper.keyword }

    let(:field) { ['keyword', 'relation.ispartof'] }

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

  describe '#repository_location' do
    subject { mapper.repository_location }

    let(:field) { 'repository.location' }

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
