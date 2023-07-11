# frozen_string_literal: true
RSpec.describe 'Hyrax events' do
  describe 'on "object.deposited" event' do
    before do
      allow(MintHandleJob).to receive(:perform_later).with(work)
    end

    let(:work) { build(:publication, id: 'pub1') }
    let(:user) { build(:user, id: 'user1') }

    it 'enqueues jobs' do
      Hyrax::Publisher.instance.publish('object.deposited', object: work, user: user)

      expect(MintHandleJob).to have_received(:perform_later).with(work).exactly(1).time
    end
  end
end
