RSpec.describe Spot::SolrizableResource do
  before do
    allow(resource).to receive(:rdf_label).and_return(rdf_label)
  end

  let(:resource) { described_class.new(language_uri) }
  let(:language_uri) { 'http://id.loc.gov/vocabulary/iso639-1/en' }
  let(:language_label) { 'English' }

  describe '#solrize' do
    subject(:solr_item) { resource.solrize }

    context 'when an rdf_label is present' do
      let(:rdf_label) { [RDF::Literal(language_label, language: :en)] }

      it { is_expected.to eq [language_uri, {label: "#{language_label}$#{language_uri}"}] }
    end

    context 'when the value is just the uri' do
      let(:rdf_label) { [language_uri] }

      it { is_expected.to eq rdf_label }
    end

    context 'when preferred language is not found' do
      let(:rdf_label) { [RDF::Literal(language_label, language: :es)] }

      it { is_expected.to eq [language_uri] }
    end
  end
end
