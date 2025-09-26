# frozen_string_literal: true
RSpec.describe BulkraxObjectFactoryFindPatch do
  describe '#find' do
    subject { find }
    let(:mock_work) { instance_double(Hyrax::Work) }
      
    context "'find_by_source_identifier' returns the object" do
      before do
        allow(Bulkrax::ObjectFactory).to receive(:find_by_source_identifier).and_return(mock_work)
      end

      expect(Bulkrax::ObjectFactory).to receive(:find_by_source_identifier)
      expect(Bulkrax::ObjectFactory).to_not receive(:find_by_id)
      expect(Bulkrax::ObjectFactory).to_not receive(:search_by_identifier)

      it { is_expected.to eq mock_work }
    end

    context "'find_by_id' returns the object" do
      before do
        allow(Bulkrax::ObjectFactory).to receive(:find_by_source_identifier).and_return(nil)
        allow(Bulkrax::ObjectFactory).to receive(:find_by_id).and_return(mock_work)
      end

      expect(Bulkrax::ObjectFactory).to receive(:find_by_source_identifier)
      expect(Bulkrax::ObjectFactory).to receive(:find_by_id)
      expect(Bulkrax::ObjectFactory).to_not receive(:search_by_identifier)

      it { is_expected.to eq mock_work }
    end

    context "'search_by_identifier' returns the object" do
      before do
        allow(Bulkrax::ObjectFactory).to receive(:find_by_source_identifier).and_return(nil)
        allow(Bulkrax::ObjectFactory).to receive(:find_by_id).and_return(nil)
        allow(Bulkrax::ObjectFactory).to receive(:search_by_identifier).and_return(mock_work)
      end

      expect(Bulkrax::ObjectFactory).to receive(:find_by_source_identifier)
      expect(Bulkrax::ObjectFactory).to receive(:find_by_id)
      expect(Bulkrax::ObjectFactory).to receive(:search_by_identifier)

      it { is_expected.to eq mock_work }
    end

    context "all methods return nil" do
      before do
        allow(Bulkrax::ObjectFactory).to receive(:find_by_source_identifier).and_return(nil)
        allow(Bulkrax::ObjectFactory).to receive(:find_by_id).and_return(nil)
        allow(Bulkrax::ObjectFactory).to receive(:search_by_identifier).and_return(nil)
      end

      expect(Bulkrax::ObjectFactory).to receive(:find_by_source_identifier)
      expect(Bulkrax::ObjectFactory).to receive(:find_by_id)
      expect(Bulkrax::ObjectFactory).to receive(:search_by_identifier)

      it { is_expected.to eq nil }
    end
  end
end
