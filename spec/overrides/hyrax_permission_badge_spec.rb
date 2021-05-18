# frozen_string_literal: true
RSpec.describe Hyrax::PermissionBadge do
  it 'adds ":metadata" to the Hash of visibility labels' do
    expect(Hyrax::PermissionBadge::VISIBILITY_LABEL_CLASS).to include(:metadata)
  end
end
