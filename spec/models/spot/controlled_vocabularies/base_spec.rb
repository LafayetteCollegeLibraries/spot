RSpec.describe Spot::ControlledVocabularies::Base do
  let(:resource) { described_class.new(uri) }
  let(:uri) { RDF::URI('http://id.loc.gov/authorities/subjects/sh85062079') }
  let(:label_en) { RDF::Literal('Horror in art', language: :en) }
  let(:label_de) { RDF::Literal('Schrecken <Motiv>', language: :de) }
  let(:labels) { [label_en, label_de] }

  before do
    allow(resource).to receive(:rdf_label).and_return(labels)
  end

  describe '#default_labels' do
    subject { resource.default_labels }

    it { is_expected.to be_an Array }
    it { is_expected.to include RDF::Vocab::GEONAMES.name }
  end

  describe '#preferred_label' do
    subject(:pref_label) { resource.preferred_label }

    context 'when a label has been cached already' do
      # need to trigger first_or_create before checking to see if it exists
      before { cache }
      after { cache.delete }

      let(:cache) { RdfLabel.first_or_create(uri: uri, value: new_label) }
      let(:new_label) { 'Cool stuff' }

      it { is_expected.to eq cache.value }

      it 'does not proceed to pick the label from the rdf data' do
        expect(resource).not_to receive(:pick_preferred_label)
      end
    end

    # this is our public method way of testing +Base#pick_preferred_label+
    context 'when a label has not been cached' do
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

    let(:generated_label) { "#{label_en}$#{uri}"}

    it { is_expected.to include uri.to_s }
    it { is_expected.to include({ label: generated_label }) }

    context 'when a label is not present' do
      before do
        allow(resource).to receive(:label_present?).and_return(false)
      end

      it { is_expected.to eq [uri.to_s] }
    end
  end
end
