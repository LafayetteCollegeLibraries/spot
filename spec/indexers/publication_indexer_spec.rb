RSpec.describe PublicationIndexer do
  let(:work) { create(:publication) }
  let(:indexer) { described_class.new(work) }
  let(:solr_doc) { indexer.generate_solr_document }

  describe 'publisher' do
    let(:solr_key) { 'publisher_ssim' }
    let(:value) { ['Cool independent press'] }

    it_behaves_like 'an indexable field'
  end

  describe 'source' do
    let(:solr_key) { 'source_ssim' }
    let(:value) { ['Origins'] }

    it_behaves_like 'an indexable field'
  end

  describe 'resource_type' do
    let(:solr_key) { 'resource_type_ssim' }
    let(:value) { ['Academic Paper'] }

    it_behaves_like 'an indexable field'
  end

  describe 'language' do
    let(:solr_key) { 'language_ssim' }
    let(:value) { ['English (American)'] }

    it { skip 'need to implement indexing by string rather than RFC-5646 value' }
  end

  describe 'abstract' do
    let(:solr_key) { 'abstract_tesim' }
    let(:value) { ['A summary of the resource'] }

    it_behaves_like 'an indexable field'
  end

  describe 'description' do
    let(:solr_key) { 'description_tesim' }
    let(:value) { ['An account of the resource'] }

    it_behaves_like 'an indexable field'
  end

  describe 'identifier' do
    let(:solr_key) { 'identifier_ssim' }
    let(:value) { ['http://cool-resource.org/abc123'] }

    it_behaves_like 'an indexable field'
  end

  describe 'issued' do
    it { skip 'needs to be implemented as date' }
  end

  describe 'available' do
    it { skip 'needs to be implemented as date' }
  end

  describe 'date_created' do
    it { skip 'needs to be implemented as date' }
  end

  describe 'creator' do
    let(:solr_key) { 'creator_ssim' }
    let(:value) { ['Applegate, K. A.'] }

    it_behaves_like 'an indexable field'
  end

  describe 'contributor' do
    let(:solr_key) { 'contributor_ssim' }
    let(:value) { ['Maysles, Albert'] }

    it_behaves_like 'an indexable field'
  end

  describe 'academic_department' do
    let(:solr_key) { 'academic_department_ssim' }
    let(:value) { ['Art'] }

    it_behaves_like 'an indexable field'
  end

  describe 'division' do
    let(:solr_key) { 'division_ssim' }
    let(:value) { ['Humanities'] }

    it_behaves_like 'an indexable field'
  end

  describe 'organization' do
    let(:solr_key) { 'organization_ssim' }
    let(:value) { ['Lafayette College'] }

    it_behaves_like 'an indexable field'
  end
end
