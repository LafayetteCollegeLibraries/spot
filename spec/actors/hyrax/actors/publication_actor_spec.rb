# frozen_string_literal: true
RSpec.describe Hyrax::Actors::PublicationActor do
  subject(:actor) { pub_actor.create(env) }

  let(:pub_actor) { described_class.new(Hyrax::Actors::Terminator.new) }
  let(:work) { Publication.new }
  let(:user) { build(:user) }
  let(:ability) { Ability.new(user) }
  let(:attributes) { {} }
  let(:env) { Hyrax::Actors::Environment.new(work, ability, attributes) }

  before { allow(work).to receive(:save) }

  describe '#apply_deposit_date' do
    before do
      allow(Hyrax::TimeService).to receive(:time_in_utc).and_return(time_value)
    end

    let(:time_value) { DateTime.now.utc }
    let(:date_uploaded) { '2018-01-08T00:00:00Z' }

    context 'when no date_uploaded value is provided' do
      it 'sets the date to TimeService.time_in_utc' do
        expect { actor }
          .to change { work.date_uploaded }
          .from(nil)
          .to(time_value)
      end
    end

    context 'when a date_uploaded is provided to the attributes' do
      let(:attributes) { { date_uploaded: date_uploaded } }

      it 'sets the date_uploaded of the work to a DateTime of the value' do
        expect { actor }
          .to change { work.date_uploaded }
          .from(nil)
          .to(DateTime.parse(date_uploaded).utc)
      end
    end

    context 'when a date_uploaded value is present on the work' do
      let(:work) { Publication.new(date_uploaded: date_uploaded) }

      it 'ensures the value is a DateTime' do
        expect { actor }
          .to change { work.date_uploaded }
          .from(date_uploaded)
          .to(DateTime.parse(date_uploaded).utc)
      end
    end
  end

  describe '#apply_date_available' do
    context 'when a date_available value is present' do
      let(:attributes) { { date_available: ['2019-11-22'] } }

      it 'does not update the value' do
        expect { actor }.not_to change { work.date_available }
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

      let(:embargo) { instance_double(Hydra::AccessControls::Embargo, embargo_release_date: tomorrow_time) }
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
