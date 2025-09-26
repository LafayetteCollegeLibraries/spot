# frozen_string_literal: true
RSpec.describe Bulkrax::ObjectFactory do
  describe '#find' do
    subject { find }
    let(:mock_work) { instance_double(Hyrax::Work) }

    context "'find_by_source_identifier' returns the object" do
      before do
        allow(Bulkrax::ObjectFactory).to receive(:find_by_source_identifier).and_return(mock_work)
      end

      it "runs the first method only and returns the object" do
        expect(Bulkrax::ObjectFactory).to receive(:find_by_source_identifier)
        expect(Bulkrax::ObjectFactory).to_not receive(:find_by_id)
        expect(Bulkrax::ObjectFactory).to_not receive(:search_by_identifier)
        is_expected.to eq mock_work
      end
    end

    context "'find_by_id' returns the object" do
      before do
        allow(Bulkrax::ObjectFactory).to receive(:find_by_source_identifier).and_return(nil)
        allow(Bulkrax::ObjectFactory).to receive(:find_by_id).and_return(mock_work)
      end

      it "runs the first two methods only and returns the object" do
        expect(Bulkrax::ObjectFactory).to receive(:find_by_source_identifier)
        expect(Bulkrax::ObjectFactory).to receive(:find_by_id)
        expect(Bulkrax::ObjectFactory).to_not receive(:search_by_identifier)
        is_expected.to eq mock_work
      end
    end

    context "'search_by_identifier' returns the object" do
      before do
        allow(Bulkrax::ObjectFactory).to receive(:find_by_source_identifier).and_return(nil)
        allow(Bulkrax::ObjectFactory).to receive(:find_by_id).and_return(nil)
        allow(Bulkrax::ObjectFactory).to receive(:search_by_identifier).and_return(mock_work)
      end

      it "runs all methods and returns the object" do
        expect(Bulkrax::ObjectFactory).to receive(:find_by_source_identifier)
        expect(Bulkrax::ObjectFactory).to receive(:find_by_id)
        expect(Bulkrax::ObjectFactory).to receive(:search_by_identifier)
        is_expected.to eq mock_work
      end
    end

    context "all methods return nil" do
      before do
        allow(Bulkrax::ObjectFactory).to receive(:find_by_source_identifier).and_return(nil)
        allow(Bulkrax::ObjectFactory).to receive(:find_by_id).and_return(nil)
        allow(Bulkrax::ObjectFactory).to receive(:search_by_identifier).and_return(nil)
      end

      it "runs all methods and returns nil" do
        expect(Bulkrax::ObjectFactory).to receive(:find_by_source_identifier)
        expect(Bulkrax::ObjectFactory).to receive(:find_by_id)
        expect(Bulkrax::ObjectFactory).to receive(:search_by_identifier)
        is_expected.to eq nil
      end
    end
  end
end
