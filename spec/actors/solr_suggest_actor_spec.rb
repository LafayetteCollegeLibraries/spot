# frozen_string_literal: true
RSpec.describe SolrSuggestActor do
  before { allow(job).to receive(:perform_now) }

  let(:job) { Spot::UpdateSolrSuggestDictionariesJob }
  let(:work) { Publication.new }
  let(:ability) { Ability.new(nil) }
  let(:env) { Hyrax::Actors::Environment.new(work, ability, attributes) }
  let(:stack) { described_class.new(Hyrax::Actors::Terminator.new) }

  context 'when not part of a batch ingest' do
    let(:attributes) { {} }

    describe '#create' do
      it 'triggers the update-dictionaries job' do
        stack.create(env)
        expect(job).to have_received(:perform_now)
      end
    end

    describe '#update' do
      it 'triggers the update-dictionaries job' do
        stack.update(env)
        expect(job).to have_received(:perform_now)
      end
    end

    describe '#destroy' do
      it 'triggers the update-dictionaries job' do
        stack.destroy(env)
        expect(job).to have_received(:perform_now)
      end
    end
  end
end
