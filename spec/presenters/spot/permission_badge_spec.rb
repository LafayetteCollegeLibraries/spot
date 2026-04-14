# frozen_string_literal: true
RSpec.describe Spot::PermissionBadge do
  it 'renders a span badge' do
    expect(described_class.new('metadata').render.to_s).to eq '<span class="badge badge-info">Metadata Only</span>'
  end

  it 'returns the correct badge_class' do
    expect(described_class.new('metadata').badge_class.to_s).to eq 'badge-info'
  end

  it 'returns the correct visibility_label' do
    expect(described_class.new('metadata').visibility_label.to_s).to eq 'Metadata Only'
  end
end
