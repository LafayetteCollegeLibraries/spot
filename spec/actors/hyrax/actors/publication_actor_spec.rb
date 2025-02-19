# frozen_string_literal: true
RSpec.describe Hyrax::Actors::PublicationActor do
  include_context 'mock remote authorities'

  it_behaves_like 'a Spot actor'

  describe '#apply_date_available' do
    let(:actor) { described_class.new(Hyrax::Actors::Terminator.new) }
    let(:work) { build(:publication, **attributes) }
    let(:user) { create(:user) }
    let(:ability) { Ability.new(user) }
    let(:attributes) { { date_available: [] } }
    let(:env) { Hyrax::Actors::Environment.new(work, ability, attributes) }

    context 'when a date_available value is present' do
      let(:attributes) { { date_available: ['2019-11-22'] } }

      it 'does not update the value' do
        actor.create(env)
        expect(work.date_available).to eq attributes[:date_available]
      end
    end

    context 'when no date_available value is present and the work is not under embargo' do
      let(:todays_date) { Time.zone.now.strftime('%Y-%m-%d') }

      # no idea why the +expect { actor }.to change .....+ syntax keeps
      # failing for this, but explicitly checking works?
      it 'updates the value to today\'s date' do
        expect(work.date_available).to eq []
        actor.create(env)
        expect(work.date_available).to eq [todays_date]
      end
    end

    context 'when an embargo is set for the work' do
      before do
        work.embargo = af_embargo
      end

      let(:embargo) do
        Hyrax::Embargo.new(
          visibility_during_embargo: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE,
          visibility_after_embargo: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
          embargo_release_date: tomorrow_time
        )
      end
      let(:af_embargo) { Hyrax.persister.resource_factory.from_resource(resource: embargo) }

      let(:tomorrow_time) { Time.zone.tomorrow }
      let(:tomorrow) { tomorrow_time.strftime('%Y-%m-%d') }

      it 'updates the value to match the embargo' do
        expect(work.date_available).to eq []
        actor.create(env)
        expect(work.date_available).to eq [tomorrow]
      end
    end
  end
end
