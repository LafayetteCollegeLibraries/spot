# frozen_string_literal: true
RSpec.describe Spot::PermissionBadge do
  it 'renders a span badge' do
    expect(described_class.new('metadata').render.to_s).to eq '<span class="badge badge-info">Metadata Only</span>'
  end
end
