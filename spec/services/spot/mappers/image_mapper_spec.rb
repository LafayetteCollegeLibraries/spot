# frozen_string_literal: true
RSpec.describe Spot::Mappers::ImageMapper do
  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  before { mapper.metadata = metadata }

  describe '#contributor' do
    subject { mapper.contributor }

    let(:field) { 'contributor' }

    it_behaves_like 'a mapped field'
  end

  describe '#creator' do
    subject { mapper.creator }

    let(:field) { 'creator' }

    it_behaves_like 'a mapped field'
  end

  describe '#date' do
    subject { mapper.date }

    let(:field) { 'date' }

    it_behaves_like 'a mapped field'
  end

  describe '#date_associated' do
    subject { mapper.date_associated }

    let(:field) { 'date_associated' }

    it_behaves_like 'a mapped field'
  end

  describe '#date_scope_note' do
    subject { mapper.date_scope_note }

    let(:field) { 'date_scope_note' }

    it_behaves_like 'a mapped field'
  end

  describe '#description' do
    subject { mapper.description }

    let(:field) { 'description' }

    it_behaves_like 'a mapped field'
  end

  describe '#donor' do
    subject { mapper.donor }

    let(:field) { 'donor' }

    it_behaves_like 'a mapped field'
  end

  describe '#inscription' do
    subject { mapper.inscription }

    let(:field) { 'inscription' }

    it_behaves_like 'a mapped field'
  end

  describe '#language' do
    subject { mapper.language }

    let(:field) { 'language' }

    it_behaves_like 'a mapped field'
  end

  describe '#location' do
    subject { mapper.location }

    let(:metadata) { { 'location' => ['http://id.worldcat.org/fast/1898429'] } }

    it { is_expected.to all be_a(RDF::URI) }
  end

  describe '#keyword' do
    subject { mapper.keyword }

    let(:field) { 'keyword' }

    it_behaves_like 'a mapped field'
  end

  describe '#note' do
    subject { mapper.note }

    let(:field) { 'note' }

    it_behaves_like 'a mapped field'
  end

  describe '#original_item_extent' do
    subject { mapper.original_item_extent }

    let(:field) { 'original_item_extent' }

    it_behaves_like 'a mapped field'
  end

  describe '#physical_medium' do
    subject { mapper.physical_medium }

    let(:field) { 'physical_medium' }

    it_behaves_like 'a mapped field'
  end

  describe '#publisher' do
    subject { mapper.publisher }

    let(:field) { 'publisher' }

    it_behaves_like 'a mapped field'
  end

  describe '#related_resource' do
    subject { mapper.related_resource }

    let(:field) { 'related_resource' }

    it_behaves_like 'a mapped field'
  end

  describe '#repository_location' do
    subject { mapper.repository_location }

    let(:field) { 'repository_location' }

    it_behaves_like 'a mapped field'
  end

  describe '#requested_by' do
    subject { mapper.requested_by }

    let(:field) { 'requested_by' }

    it_behaves_like 'a mapped field'
  end

  describe '#research_assistance' do
    subject { mapper.research_assistance }

    let(:field) { 'research_assistance' }

    it_behaves_like 'a mapped field'
  end

  describe '#resource_type' do
    subject { mapper.resource_type }

    let(:field) { 'resource_type' }

    it_behaves_like 'a mapped field'
  end

  describe '#rights_holder' do
    subject { mapper.rights_holder }

    let(:field) { 'rights_holder' }

    it_behaves_like 'a mapped field'
  end

  describe '#rights_statement' do
    subject { mapper.rights_statement }

    let(:metadata) { { 'rights_statement' => ['http://creativecommons.org/licenses/by-nc-sa/4.0/'] } }

    it { is_expected.to all be_a(RDF::URI) }
  end


  describe '#source' do
    subject { mapper.source }

    let(:field) { 'source' }

    it_behaves_like 'a mapped field'
  end

  describe '#subject' do
    subject { mapper.subject }

    let(:metadata) { { 'subject' => ['http://id.worldcat.org/fast/967482'] } }

    it { is_expected.to all be_a(RDF::URI) }
  end

  describe '#subject_ocm' do
    subject { mapper.subject_ocm }

    let(:field) { 'subject_ocm' }

    it_behaves_like 'a mapped field'
  end

  describe '#subtitle' do
    subject { mapper.subtitle }

    let(:field) { 'subtitle' }

    it_behaves_like 'a mapped field'
  end

  describe '#title' do
    subject { mapper.title }

    let(:field) { 'title' }

    it_behaves_like 'a mapped field'
  end

  describe '#title_alternative' do
    subject { mapper.title_alternative }

    let(:field) { 'title_alternative' }

    it_behaves_like 'a mapped field'
  end

end
