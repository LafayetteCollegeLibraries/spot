# frozen_string_literal: true
RSpec.describe Hyrax::Actors::PublicationActor do
  it_behaves_like 'a Spot actor'

  describe '#apply_date_available' do
    subject(:actor) { actor_stack.create(env) }

    let(:actor_stack) { described_class.new(Hyrax::Actors::Terminator.new) }
    let(:work) { build(:publication, **attributes) }
    let(:user) { create(:user) }
    let(:ability) { Ability.new(user) }
    let(:attributes) { { date_available: [] } }
    let(:env) { Hyrax::Actors::Environment.new(work, ability, attributes) }

    context 'when a date_available value is present' do
      let(:attributes) { { date_available: ['2019-11-22'] } }

      it 'does not update the value' do
        actor
        expect(work.date_available).to eq attributes[:date_available]
      end
    end

    context 'when no date_available value is present and the work is not under embargo' do
      let(:todays_date) { Time.zone.now.strftime('%Y-%m-%d') }

      # no idea why the +expect { actor }.to change .....+ syntax keeps
      # failing for this, but explicitly checking works?
      it 'updates the value to today\'s date' do
        expect(work.date_available).to eq []
        actor
        expect(work.date_available).to eq [todays_date]
      end
    end

    context 'when an embargo is set for the work' do
      before { allow(work).to receive(:embargo).and_return embargo }

      let(:embargo) do
        instance_double(Hydra::AccessControls::Embargo,
                        embargo_release_date: tomorrow_time,
                        to_hash: {})
      end
      let(:tomorrow_time) { Time.zone.tomorrow }
      let(:tomorrow) { tomorrow_time.strftime('%Y-%m-%d') }

      it 'updates the value to match the embargo' do
        expect(work.date_available).to eq []
        actor
        expect(work.date_available).to eq [tomorrow]
      end
    end
  end
end
