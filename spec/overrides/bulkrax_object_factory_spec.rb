# frozen_string_literal: true
RSpec.describe Bulkrax::ObjectFactory do
  describe '#find' do
    subject { described_class.find }
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

  describe '#find_by_source_identifier' do
    subject { described_class.find_by_source_identifier }

    context "there is no source_identifier" do
      let(:attributes) { { 'source_identifier': nil } }

      it { is_expected.to eq nil }
    end

    context "there is a source_identifier" do
      let(:identifier) { "test_0_0" }
      let(:attributes) { { 'source_identifier': [identifier] } }

      context "the solr query does not match with an object" do
        before do
          allow(Hyrax::SolrService).to receive(:get).with("source_identifier_ssim:#{identifier}", fl: ['id', 'source_identifier_ssim'], defType: 'lucene').and_return(nil)
        end

        it { is_expected.to eq nil }
      end

      context "the solr query matches with an object" do
        context "the id is empty" do
          let(:id_doc) { { 'response': { 'docs': [{ 'id': nil }] } } }

          before do
            allow(Hyrax::SolrService).to receive(:get).with("source_identifier_ssim:#{ identifier }", fl: ['id', 'source_identifier_ssim'], defType: 'lucene').and_return(id_doc)
          end

          it { is_expected.to eq nil }
        end

        context "the id is not empty" do
          let(:id) { "0a0a0a0a" }
          let(:id_doc) { { 'response': { 'docs': [{ 'id': id }] } } }
          let(:mock_work) { instance_double(Hyrax::Work) }

          before do
            allow(Hyrax::SolrService).to receive(:get).with("source_identifier_ssim:#{ identifier }", fl: ['id', 'source_identifier_ssim'], defType: 'lucene').and_return(id_doc)
            allow(ActiveFedora::Base).to receive(:find).with(id).and_return(mock_work)
          end

          it { is_expected.to eq mock_work }
        end
      end
    end
  end
end
