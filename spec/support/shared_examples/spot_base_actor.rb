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
    let(:expected) { { 'rights_statement' => [RDF::URI(uri)] } }

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

  describe '#update_discover_visibility' do
    let(:actor) { Hyrax::Actors::InterpretVisibilityActor.new(described_class.new(Hyrax::Actors::Terminator.new)) }
    let(:attributes) { { visibility: viz } }

    let(:public_viz) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    let(:private_viz) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
    let(:authenticated_viz) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED }
    let(:embargoed_viz) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO }
    let(:leased_viz) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_LEASE }

    shared_examples 'it adjusts work#discover_groups based on desired visibility' do
      # we're gonna use these two a lot in this example, so let's set up shared_examples
      shared_examples 'it adds "public" to #discover_groups' do
        subject { work.discover_groups }

        it { is_expected.to be_an(Array) }
        it { is_expected.to include('public') }
      end

      shared_examples 'it adds nothing to #discover_groups' do
        subject { work.discover_groups }

        it { is_expected.to be_an(Array) }
        it { is_expected.to be_empty }
      end

      # now the different contexts:
      context 'when visibility requested is "public"' do
        let(:viz) { public_viz }

        it_behaves_like 'it adds "public" to #discover_groups'
      end

      context 'when visibility requested is "private"' do
        let(:viz) { private_viz }

        it_behaves_like 'it adds nothing to #discover_groups'
      end

      context 'when embargo is requested' do
        let(:attributes) do
          {
            visibility: embargoed_viz,
            visibility_during_embargo: viz_during_embargo,
            visibility_after_embargo: public_viz,
            embargo_release_date: (Time.zone.today + 1.year).to_s
          }
        end

        context '(work is public during embargo)' do
          let(:viz_during_embargo) { public_viz }

          it_behaves_like 'it adds "public" to #discover_groups'
        end

        context '(work is authenticated during embargo)' do
          let(:viz_during_embargo) { authenticated_viz }

          it_behaves_like 'it adds "public" to #discover_groups'
        end

        context '(work is private during embargo)' do
          let(:viz_during_embargo) { private_viz }

          it_behaves_like 'it adds nothing to #discover_groups'
        end
      end
    end

    context '#create' do
      before { actor.create(env) }

      it_behaves_like 'it adjusts work#discover_groups based on desired visibility'
    end

    context '#update' do
      let(:work) { create(work_klass.to_s.downcase.to_sym, :public, discover_groups: ['public']) }

      before { actor.update(env) }

      it_behaves_like 'it adjusts work#discover_groups based on desired visibility'

      context 'when a public item becomes private' do
        let(:attributes) { { visibility: private_viz } }

        it 'removes "public" from work#discover_groups' do
          expect(work.discover_groups).to be_empty
        end
      end
    end
  end
end
