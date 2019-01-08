# frozen_string_literal: true
RSpec.describe Hyrax::Actors::PublicationActor do
  let(:actor) { described_class.new(Hyrax::Actors::Terminator.new) }

  # thumbs-down to testing a private method, but this is (currently) the only
  # thing we've changed in PublicationActor
  describe '#apply_deposit_date' do
    subject(:apply_date) { actor.send(:apply_deposit_date, env) }

    let(:work) { Publication.new }
    let(:user) { build(:user) }
    let(:ability) { Ability.new(user) }
    let(:attributes) { {} }
    let(:env) { Hyrax::Actors::Environment.new(work, ability, attributes) }
    let(:date_uploaded) { '2018-01-08T00:00:00Z' }

    context 'when no date_uploaded value is provided' do
      before do
        allow(Hyrax::TimeService).to receive(:time_in_utc).and_return(time_value)
      end

      let(:time_value) { DateTime.now.utc }

      it 'sets the date to TimeService.time_in_utc' do
        expect { apply_date }
          .to change { work.date_uploaded }
          .from(nil)
          .to(time_value)
      end
    end

    context 'when a date_uploaded is provided to the attributes' do
      let(:attributes) { { date_uploaded: date_uploaded } }

      it 'sets the date_uploaded of the work to a DateTime of the value' do
        expect { apply_date }
          .to change { work.date_uploaded }
          .from(nil)
          .to(DateTime.parse(date_uploaded).utc)
      end
    end

    context 'when a date_uploaded value is present on the work' do
      let(:work) { Publication.new(date_uploaded: date_uploaded) }

      it 'ensures the value is a DateTime' do
        expect { apply_date }
          .to change { work.date_uploaded }
          .from(date_uploaded)
          .to(DateTime.parse(date_uploaded).utc)
      end
    end
  end
end
