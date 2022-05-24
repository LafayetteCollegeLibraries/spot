# frozen_string_literal: true
RSpec.describe Spot::ControlledVocabularies::Base do
  let(:resource) { described_class.new(uri) }
  let(:uri) { RDF::URI('http://id.loc.gov/authorities/subjects/sh85062079') }
  let(:label_en) { RDF::Literal('Horror in art', language: :en) }
  let(:label_de) { RDF::Literal('Schrecken <Motiv>', language: :de) }
  let(:labels) { [label_en, label_de] }
  let(:graph) { RDF::Graph.new.tap { |graph| statements.each { |stmt| graph << stmt } } }
  let(:statements) { labels.map { |label| RDF::Statement(resource, RDF::Vocab::SKOS.prefLabel, label) } }

  before do
    stub_request(:get, uri.to_s).to_return(status: 200, body: graph.dump(:ttl))
  end

  describe '#default_labels' do
    subject { resource.default_labels }

    it { is_expected.to be_an Array }
    it { is_expected.to include RDF::Vocab::GEONAMES.name }
  end

  describe '#fetch' do
    subject(:fetch) { resource.fetch }

    context 'retrying #fetch when it initially fails' do
      before do
        stub_request(:any, uri).and_return(status: [500, 'Internal Server Error'])
        allow(resource).to receive(:sleep).and_return(true)
      end

      after { WebMock.reset! }

      it 'retries 3 times' do
        fetch

        # 3 tries, minus the first try
        expect(resource).to have_received(:sleep).exactly(2).times
      end

      it_behaves_like 'it logs a warning'
    end

    context 'when a label has not been cached but others exist' do
      before do
        RdfLabel.destroy_all
        RdfLabel.create!(uri: 'http://cool.org/example', value: 'a previous example')

        stub_request(:any, uri)
        allow(resource).to receive(:pick_preferred_label).and_return(label_en)
      end

      it 'adds another entry to the cache' do
        fetch

        expect(RdfLabel.count).to be > 1
      end
    end

    context 'when a label already exists' do
      before do
        RdfLabel.create(uri: uri.to_s, value: label_en.to_s)
        stub_request(:any, uri.to_s)

        resource.fetch
      end

      after do
        RdfLabel.find_by(uri: uri.to_s)&.destroy
      end

      it 'does not make a remote call' do
        expect(resource.rdf_label).to eq [label_en.to_s]
        expect(a_request(:get, 'http://id.loc.gov')).not_to have_been_made
      end
    end
  end

  describe '#preferred_label' do
    subject(:pref_label) { resource.preferred_label }

    context 'when a label has been cached already' do
      before do
        allow(resource).to receive(:pick_preferred_label)
        # need to trigger first_or_create before checking to see if it exists
        cache

        resource.fetch
      end

      after { cache.delete }

      let(:cache) { RdfLabel.create!(uri: uri, value: new_label) }
      let(:new_label) { 'Cool stuff' }

      it { is_expected.to eq cache.value }

      it 'does not proceed to pick the label from the rdf data' do
        expect(resource).not_to have_received(:pick_preferred_label)
      end
    end

    # this is our public method way of testing +Base#pick_preferred_label+
    context 'when a label has not been cached' do
      before { resource.fetch }

      context 'when an English value exists' do
        it { is_expected.to eq label_en.to_s }
      end

      context 'when an English value does not exist' do
        let(:labels) { [label_de] }

        it { is_expected.to eq labels.first.to_s }
      end
    end
  end

  describe '#solrize' do
    subject { resource.solrize }

    let(:generated_label) { "#{label_en}$#{uri}" }

    before do
      resource.fetch
    end

    it { is_expected.to include uri.to_s }
    it { is_expected.to include(label: generated_label) }

    context 'when a label is not present' do
      before do
        allow(resource).to receive(:label_present?).and_return(false)
      end

      it { is_expected.to eq [uri.to_s] }
    end
  end
end
