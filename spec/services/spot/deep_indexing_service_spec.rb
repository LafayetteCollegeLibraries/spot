# frozen_string_literal: true
RSpec.describe Spot::DeepIndexingService do
  describe '#generate_solr_document' do
    subject(:doc) { indexing_service.generate_solr_document }

    let(:indexing_service) { described_class.new(object, object.class.index_config) }
    let(:metadata) do
      { title: ['Fake work title'], location: [RDF::URI(location_uri)] }
    end
    let(:location_uri) { 'http://sws.geonames.org/4931353/' }
    let(:location_label) { 'Brighton' }
    let(:object) { work_class.new(metadata) }

    # geonames doesn't actually give us n-triples, but let's pretend it does
    let(:rdf_body) do
      %(<#{location_uri}> <http://www.geonames.org/ontology#name> "#{location_label}"@en . )
    end

    # this is a bit much, but i'd rather not rely on fields that may change
    # in the future (but not have any bearing on this service).
    let(:work_class) do
      Class.new(ActiveFedora::Base) do
        class_attribute :controlled_properties
        self.controlled_properties = [:location]

        property :title, predicate: RDF::Vocab::DC.title do |index|
          index.as :stored_searchable
        end

        property :location,
                 predicate: RDF::Vocab::DC.spatial,
                 class_name: Spot::ControlledVocabularies::Base do |index|
          index.as :handled_by_deep_indexing_service
        end
      end
    end

    before do
      stub_request(:any, location_uri).to_return(body: rdf_body)
    end

    # it indexes our expected fields
    it { is_expected.to include 'title_tesim' }
    it { is_expected.to include 'location_ssim' }
    it { is_expected.to include 'location_label_sim' }
    it { is_expected.to include 'location_label_tesim' }

    context 'when a cached label exists' do
      before do
        RdfLabel.create(uri: location_uri, value: location_label)
        allow(object.location.first).to receive(:fetch)
      end

      it 'does not fetch the label' do
        expect(object.location.first).not_to have_received(:fetch)
      end

      it { is_expected.to include 'location_ssim' }
      it { is_expected.to include 'location_label_sim' }
      it { is_expected.to include 'location_label_tesim' }
    end

    context 'when a label is not cached' do
      before do
        RdfLabel.where(uri: location_uri, value: location_label).delete_all
        allow(object.location.first).to receive(:fetch)
      end

      it 'fetches the label' do
        indexing_service.generate_solr_document

        expect(object.location.first).to have_received(:fetch)
      end
    end
  end
end
