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

    describe 'indexes standard/local identifiers' do
      let(:metadata) { { identifier: ['issn:0000-0000', 'noid:abc123def', 'lafayette:magazine_112', 'nil-identifier']} }

      it 'indexes "standard" identifiers to identifier_standard_ssim' do
        expect(solr_document['identifier_standard_ssim']).to eq ['issn:0000-0000']
      end

      it 'indexes unknown identifier prefixes to identifier_local_ssim' do
        expect(solr_document['identifier_local_ssim']).to eq ['noid:abc123def', 'lafayette:magazine_112', 'nil-identifier']
      end
    end

    describe 'indexes thumbnail url' do
      subject { solr_document['thumbnail_url_ss'] }

      let(:metadata) { { thumbnail_id: 'fs-ghi456jkl' } }
      let(:download_path) { 'http://cool-host.org/download/fsabc123def?file=thumbnail'}
      let(:file_set_type_service_mock) { instance_double(Hyrax::FileSetTypeService, audio?: is_audio) }
      let(:is_audio) { false }

      before do
        allow(Hyrax.query_service)
        .to receive(:find_by_alternate_identifier)
        .with(alternate_identifier: resource.thumbnail_id)
        .and_return(file_set)

        allow(File)
          .to receive(:exist?)
          .with(Hyrax::DerivativePath.derivative_path_for_reference(file_set, 'thumbnail'))
          .and_return(true)

        allow(Hyrax::FileSetTypeService)
          .to receive(:new)
          .with(file_set: file_set)
          .and_return(file_set_type_service_mock)

        stub_env('URL_HOST', url_host)
      end

      # Want to make sure we support both FileSet classes during the migration.
      [FileSet, Hyrax::FileSet].each do |klass|
        context "with #{klass}" do
          subject(:thumbnail_url) { solr_document['thumbnail_url_ss'] }

          let(:file_set) { instance_double(klass, id: metadata[:thumbnail_id], file_set?: true) }

          context 'when URL_HOST is set in the environment' do
            let(:url_host) { 'http://cool-host.org' }

            it { is_expected.to eq 'http://cool-host.org/downloads/fs-ghi456jkl?file=thumbnail' }

            context 'when a file_set is an audio file' do
              let(:is_audio) { true }

              it 'uses the default audio thumbnail' do
                expect(thumbnail_url).to match(/^http:\/\/cool-host\.org\/assets\/audio-[a-z0-9]+\.png$/)
              end
            end
          end

          context 'when URL_HOST is not set' do
            let(:url_host) { nil }
            it { is_expected.to be nil }
          end

        end
      end
    end
  end
end
