RSpec.describe Hyrax::PublicationForm do
  shared_context 'required fields' do
    it 'contains required fields' do
      expect(subject).to include :title
      expect(subject).to include :contributor
      expect(subject).to include :date_created
      expect(subject).to include :issued
      expect(subject).to include :available
      expect(subject).to include :rights_statement
    end
  end

  describe '.required_fields' do
    subject { described_class.required_fields }

    include_context 'required fields'
  end

  describe '.terms' do
    subject(:terms) { described_class.terms }

    include_context 'required fields'

    it 'includes optional fields' do
      expect(terms).to include :creator
      expect(terms).to include :publisher
      expect(terms).to include :source
      expect(terms).to include :resource_type
      expect(terms).to include :language
      expect(terms).to include :abstract
      expect(terms).to include :description
      expect(terms).to include :identifier
      expect(terms).to include :academic_department
      expect(terms).to include :division
      expect(terms).to include :organization
    end

    it 'includes internal_form_fields' do
      expect(terms).to include :representative_id
      expect(terms).to include :thumbnail_id
      expect(terms).to include :files
      expect(terms).to include :visibility_during_embargo
      expect(terms).to include :visibility_after_embargo
      expect(terms).to include :embargo_release_date
      expect(terms).to include :visibility_during_lease
      expect(terms).to include :visibility_after_lease
      expect(terms).to include :lease_expiration_date
      expect(terms).to include :visibility
      expect(terms).to include :ordered_member_ids
      expect(terms).to include :in_works_ids
      expect(terms).to include :member_of_collection_ids
      expect(terms).to include :admin_set_id
    end
  end

  describe '.multiple?' do
    it 'marks singular fields as false' do
      expect(described_class.multiple?('title')).to be false
      expect(described_class.multiple?('type')).to be false
      expect(described_class.multiple?('abstract')).to be false
      expect(described_class.multiple?('issued')).to be false
      expect(described_class.multiple?('available')).to be false
      expect(described_class.multiple?('date_created')).to be false
    end
  end
end
