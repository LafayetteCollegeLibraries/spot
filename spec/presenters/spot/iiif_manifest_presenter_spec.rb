# frozen_string_literal: true
RSpec.describe Spot::IiifManifestPresenter do
  subject(:presenter) { described_class.new(solr_document) }

  let(:ability) { Ability.new(nil) }
  let(:metadata_fields) { [:title, :title_alternative] }
  let(:raw_doc) do
    { 'id' => 'test1', 'title_tesim' => ['Work Title'], 'title_alternative_tesim' => ['Another Title for Work'], visibility_ssi: 'open' }
  end
  let(:solr_document) { SolrDocument.new(raw_doc) }

  before do
    @iiif_metadata_fields = Hyrax.config.iiif_metadata_fields
    Hyrax.config.iiif_metadata_fields = metadata_fields

    presenter.ability = ability
  end

  after do
    Hyrax.config.iiif_metadata_fields = @iiif_metadata_fields
  end

  describe '#manifest_metadata' do
    subject(:metadata) { presenter.manifest_metadata }

    let(:expected_metadata) do
      [
        { 'label' => 'Title', 'value' => ['Work Title'] },
        { 'label' => 'Alternative Title', 'value' => ['Another Title for Work'] }
      ]
    end

    it { is_expected.to eq(expected_metadata) }
  end
end
