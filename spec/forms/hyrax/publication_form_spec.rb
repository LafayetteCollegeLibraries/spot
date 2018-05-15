RSpec.describe Hyrax::PublicationForm do
  shared_context 'required fields' do
    it 'contains required fields' do
      expect(subject).to include :title
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
      expect(terms).to include :contributor
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
    subject(:form) { described_class.new(Publication.new, nil, nil) }

    it 'marks singular fields as false' do
      expect(form.multiple?('resource_type')).to be false
      expect(form.multiple?('abstract')).to be false
      expect(form.multiple?('issued')).to be false
      expect(form.multiple?('available')).to be false
      expect(form.multiple?('date_created')).to be false
    end

    it 'marks multiple fields as true' do
      expect(form.multiple?('title')).to be true
      expect(form.multiple?('creator')).to be true
      expect(form.multiple?('contributor')).to be true
      expect(form.multiple?('publisher')).to be true
      expect(form.multiple?('source')).to be true
      expect(form.multiple?('language')).to be true
      expect(form.multiple?('description')).to be true
      expect(form.multiple?('identifier')).to be true
      expect(form.multiple?('academic_department')).to be true
      expect(form.multiple?('division')).to be true
      expect(form.multiple?('organization')).to be true
    end
  end
end
