# frozen_string_literal: true
RSpec.shared_examples 'a BaseResourceIndexer' do
  describe 'base_metadata fields' do
    # base metadata
    it_behaves_like 'it indexes', :bibliographic_citation, to: ['bibliographic_citation_tesim']
    it_behaves_like 'it indexes', :contributor, to: ['contributor_tesim', 'contributor_sim']
    it_behaves_like 'it indexes', :creator, to: ['creator_tesim', 'creator_sim']
    it_behaves_like 'it indexes', :description, to: ['description_tesim']
    it_behaves_like 'it indexes', :identifier, to: ['identifier_ssim']
    it_behaves_like 'it indexes', :keyword, to: ['keyword_tesim', 'keyword_sim']
    it_behaves_like 'it indexes', :language, to: ['language_ssim'] # see below for language_labels
    it_behaves_like 'it indexes', :location, to: ['location_ssim']
    it_behaves_like 'it indexes', :note, to: ['note_tesim']
    it_behaves_like 'it indexes', :physical_medium, to: ['physical_medium_tesim', 'physical_medium_sim']
    it_behaves_like 'it indexes', :publisher, to: ['publisher_tesim', 'publisher_sim']
    it_behaves_like 'it indexes', :related_resource, to: ['related_resource_tesim', 'related_resource_sim']
    it_behaves_like 'it indexes', :resource_type, to: ['resource_type_ssim']
    it_behaves_like 'it indexes', :rights_holder, to: ['rights_holder_tesim', 'rights_holder_sim']
    it_behaves_like 'it indexes', :rights_statement, to: ['rights_statement_ssim']
    it_behaves_like 'it indexes', :source, to: ['source_tesim', 'source_sim']
    it_behaves_like 'it indexes', :source_identifier, to: ['source_identifier_ssim']
    it_behaves_like 'it indexes', :subject, to: ['subject_ssim']
    it_behaves_like 'it indexes', :subtitle, to: ['subtitle_tesim', 'subtitle_sim']
    it_behaves_like 'it indexes', :title_alternative, to: ['title_alternative_tesim', 'title_alternative_sim']
  end

  describe 'field indexing' do
    subject(:indexer) { described_class.for(resource: resource) }
    let(:resource_factory) { described_class.name.split('::').last.gsub(/Indexer$/, '').underscore.to_sym }
    let(:resource) { build(resource_factory, **metadata) }
    let(:metadata) { {} }
    let(:solr_document) { indexer.to_solr }

    describe 'permalink_urls' do
      subject(:permalink_url) { solr_document['permalink_ss'] }

      context 'when the resource has a Handle identifier' do
        let(:metadata) { { identifier: ['hdl:10385/abc123def'] } }

        it 'uses the Handle URL' do
          expect(permalink_url).to eq 'http://hdl.handle.net/10385/abc123def'
        end
      end

      context 'when the resource has no Handle identifier but is persisted' do
        before do
          allow(resource).to receive(:persisted?).and_return(true)
        end

        let(:id) { SecureRandom.hex }
        let(:resource) { build(resource_factory, **metadata) }
        let(:metadata) { { id: id, identifier: ['laf:test_id'] } }

        let(:rails_url) { URI.join(ENV['URL_HOST'], "/concern/#{resource_factory.to_s.gsub(/_resource$/, '').pluralize}/#{id}") }

        it 'uses the Rails URL' do
          expect(permalink_url).to eq rails_url.to_s
        end
      end
    end

    describe 'title sort' do
      subject { solr_document['title_sort_si'] }

      let(:metadata) { { title: ['A Primary Title', 'Some Secondary Title'] } }

      it { is_expected.to eq 'a primary title' }
    end

    describe 'date sort' do
      subject { solr_document['date_sort_dtsi'] }

      let(:date_property) { described_class.sortable_date_property }

      context 'when the resource has values for the date_property' do
        let(:metadata) { { date_property => ['2023-10-21', '1986-02-11', '1991-09-04'] } }

        it { is_expected.to eq '1986-02-11T00:00:00Z' }
      end

      context 'when the resource has no values for the date_property, but was persisted' do
        let(:created_date) { DateTime.now.utc }
        let(:metadata) { { date_property => [], :created_at => created_date } }

        it { is_expected.to eq created_date.strftime('%FT%TZ') }
      end

      context 'when the resource has not been persisted and has no values' do
        let(:resource) { resource_factory.to_s.camelize.constantize.new }

        it { is_expected.to be nil }
      end
    end

    describe 'indexes language labels' do
      let(:metadata) { { language: ['eng', 'ita'] } }

      context 'label values' do
        it 'are generated' do
          expect(solr_document['language_label_ssim']).to eq ['English', 'Italian']
        end
      end
    end
    # identifier_standard
    # identifier_local
    # language and label
    # thumbnail url
  end
end
