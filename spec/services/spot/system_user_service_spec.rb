# frozen_string_literal: true
RSpec.describe Spot::SystemUserService do
  describe '.audit_user' do
    subject(:audit_user) { described_class.audit_user }

    it 'creates a user for performing auditing actions' do
      expect(audit_user).to be_a User
      expect(audit_user.display_name).to eq described_class::AUDIT_USER_DISPLAY_NAME
      expect(audit_user.email).to eq described_class::AUDIT_USER_EMAIL
    end

    it { is_expected.to be_admin }
  end

  describe '.batch_user' do
    subject(:batch_user) { described_class.batch_user }

    it 'creates a user for performing batch actions' do
      expect(batch_user).to be_a User
      expect(batch_user.display_name).to eq described_class::BATCH_USER_DISPLAY_NAME
      expect(batch_user.email).to eq described_class::BATCH_USER_EMAIL
    end

    it { is_expected.to be_admin }
  end
end
