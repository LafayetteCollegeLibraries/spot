# frozen_string_literal: true
RSpec.describe 'Hyrax callbacks' do
  describe ':after_create_concern' do
    before do
      allow(ContentDepositEventJob).to receive(:perform_later).with(work, user)
      allow(MintHandleJob).to receive(:perform_later).with(work)
    end

    let(:work) { build(:publication) }
    let(:user) { build(:user) }

    it 'enqueues jobs' do
      Hyrax.config.callback.run(:after_create_concern, work, user)

      expect(ContentDepositEventJob).to have_received(:perform_later).with(work, user).exactly(1).time
      expect(MintHandleJob).to have_received(:perform_later).with(work).exactly(1).time
    end
  end
end
