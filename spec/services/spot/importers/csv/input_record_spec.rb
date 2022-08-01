# frozen_string_literal: true
RSpec.describe Spot::Importers::CSV::InputRecord, feature: :csv_ingest_service do
  describe '#attributes' do
    let(:input_record) { described_class.from(metadata: metadata, mapper: mapper) }
    let(:mapper) { Spot::Importers::CSV::WorkTypeMapper.for(:publication) }

    context 'when metadata has empty values for attributes' do
      let(:metadata) { { title: ['Publication Title'], creator: [] } }

      it 'filters them out' do
        expect(input_record.attributes).not_to include(:creator)
      end
    end
  end
end
