RSpec.describe User do
  describe '#trustee?' do
    context "when a user's groups contain 'trustee'" do
      subject { create(:trustee) }

      its(:trustee?) { is_expected.to be true }
    end

    context "when a user's groups do not contain 'trustee'" do
      subject { create(:user) }

      its(:trustee?) { is_expected.to be false }
    end
  end
end
