# frozen_string_literal: true
RSpec.describe Hydra::AccessControls::Embargo do
  describe '#active?' do
    let(:embargo) do
      described_class.new(visibility_during_embargo: 'restricted',
                          visibility_after_embargo: 'open',
                          embargo_release_date: Date.today.to_s)
    end

    it 'returns false if the release date is today' do
      expect(embargo.active?).to be false
    end
  end
end

RSpec.describe Hydra::AccessControls::Lease do
  describe '#active?' do
    let(:lease) do
      described_class.new(visibility_during_lease: 'open',
                          visibility_after_lease: 'restricted',
                          lease_expiration_date: Date.today.to_s)
    end

    it 'returns false if the expiration date is today' do
      expect(lease.active?).to be false
    end
  end
end
