RSpec.describe Hyrax::DocumentForm do
  describe '.required_fields' do
    subject { described_class.required_fields }

    it { is_expected.to include :title }
    it { is_expected.to include :contributor }
  end

  describe '.terms' do
    subject { described_class.terms }

    it { is_expected.to include :title }
    it { is_expected.to include :contributor }
    it { is_expected.to include :creator }
    it { is_expected.to include :language }
    it { is_expected.to include :abstract }
    it { is_expected.to include :description }
    it { is_expected.to include :identifier }
    it { is_expected.to include :issued }
    it { is_expected.to include :publisher }
    it { is_expected.to include :date_created }
    it { is_expected.to include :provenance }
    it { is_expected.to include :department }
    it { is_expected.to include :division }
    it { is_expected.to include :organization }
    it { is_expected.to include :subject }
    it { is_expected.to include :related_url }
    it { is_expected.to include :source }
    it { is_expected.to include :license }
    it { is_expected.to include :rights_statement }
    it { is_expected.to include :representative_id }
    it { is_expected.to include :thumbnail_id }
    it { is_expected.to include :files }
    it { is_expected.to include :visibility_during_embargo }
    it { is_expected.to include :visibility_after_embargo }
    it { is_expected.to include :embargo_release_date }
    it { is_expected.to include :visibility_during_lease }
    it { is_expected.to include :visibility_after_lease }
    it { is_expected.to include :lease_expiration_date }
    it { is_expected.to include :visibility }
    it { is_expected.to include :ordered_member_ids }
    it { is_expected.to include :in_works_ids }
    it { is_expected.to include :member_of_collection_ids }
    it { is_expected.to include :admin_set_id }
  end
end
