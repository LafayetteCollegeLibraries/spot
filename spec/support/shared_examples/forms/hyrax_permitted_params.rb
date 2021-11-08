# frozen_string_literal: true
RSpec.shared_examples 'it builds Hyrax permitted params' do
  subject { described_class.build_permitted_params }

  it { is_expected.to include(:representative_id, :thumbnail_id) }
  it { is_expected.to include(rendering_ids: []) }
  it { is_expected.to include(files: []) }
  it {
  is_expected.to include(:visibility_during_embargo, :embargo_release_date,
                         :visibility_after_embargo, :visibility_during_lease,
                         :lease_expiration_date, :visibility_after_lease, :visibility)
  }
  it { is_expected.to include(ordered_member_ids: []) }
  it { is_expected.to include(in_works_ids: []) }
  it { is_expected.to include(member_of_collection_ids: []) }
  it { is_expected.to include(:admin_set_id) }
  it { is_expected.to include(permissions_attributes: [:type, :name, :access, :id, :_destroy]) }
  it { is_expected.to include(:on_behalf_of, :version, :add_works_to_collection) }
end
