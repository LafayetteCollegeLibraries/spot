# frozen_string_literal: true
RSpec.shared_examples 'a Spot actor' do
  let(:actor) { described_class.new(Hyrax::Actors::Terminator.new) }
  let(:work_klass) { described_class.name.split('::').last.gsub(/Actor$/, '').constantize }
  let(:work) { work_klass.new }
  let(:user) { create(:user) }
  let(:ability) { Ability.new(user) }
  let(:attributes) { attributes_for(work_klass.to_s.downcase.to_sym) }
  let(:env) { Hyrax::Actors::Environment.new(work, ability, attributes) }

  describe '#apply_deposit_date' do
    before do
      allow(work).to receive(:save)
      allow(Hyrax::TimeService).to receive(:time_in_utc).and_return(time_value)
    end

    let(:time_value) { DateTime.now.utc }
    let(:date_uploaded) { '2018-01-08T00:00:00Z' }

    context 'when no date_uploaded value is provided' do
      it 'sets the date to TimeService.time_in_utc' do
        expect { actor.create(env) }
          .to change { work.date_uploaded }
          .from(nil)
          .to(time_value)
      end
    end

    context 'when a date_uploaded is provided to the attributes' do
      let(:attributes) { { date_uploaded: date_uploaded } }

      it 'sets the date_uploaded of the work to a DateTime of the value' do
        expect { actor.create(env) }
          .to change { work.date_uploaded }
          .from(nil)
          .to(DateTime.parse(date_uploaded).utc)
      end
    end

    context 'when a date_uploaded value is present on the work' do
      let(:work) { work_klass.new(date_uploaded: date_uploaded) }

      it 'ensures the value is a DateTime' do
        expect { actor.create(env) }
          .to change { work.date_uploaded }
          .from(date_uploaded)
          .to(DateTime.parse(date_uploaded).utc)
      end
    end
  end

  describe 'enqueues MintHandleJob on #create' do
    before { allow(MintHandleJob).to receive(:perform_later).with(work) }

    it 'enqueues MintHandleJob' do
      actor.create(env)

      expect(MintHandleJob).to have_received(:perform_later).with(work)
    end
  end

  describe 'converts rights_statement values to RDF::URIs' do
    let(:uri) { 'http://creativecommons.org/publicdomain/mark/1.0/' }
    let(:attributes) { { rights_statement: uri } }
    let(:expected) { { rights_statement: [RDF::URI(uri)] } }

    context '#create' do
      before { actor.create(env) }

      it 'converts rights_statement uri strings to RDF::URI objects' do
        expect(env.attributes).to eq expected
      end
    end

    context '#update' do
      before { actor.update(env) }

      it 'converts rights_statement uri strings to RDF::URI objects' do
        expect(env.attributes).to eq expected
      end
    end
  end
end
