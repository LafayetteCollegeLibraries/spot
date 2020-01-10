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
