# frozen_string_literal: true
RSpec.describe Spot::IiifManifestPresenter do
  let(:presenter) { described_class.new(document) }
  let(:document) { SolrDocument.new(solr_attributes) }

  describe '#manifest_metadata' do
    subject(:manifest_metadata) { presenter.manifest_metadata.first }

    let(:solr_attributes) { { 'title_alternative_tesim' => ['Another Title to the Work'] } }

    describe 'locale handling' do
      context 'when a field has a locale' do
        it { is_expected.to include 'label' => 'Alternative Title' }
        it { is_expected.to include 'value' => ['Another Title to the Work'] }
      end

      context 'when a field does not have a locale' do
        before do
          @old_locale = I18n.locale
          I18n.locale = :fr # we currently don't support french
        end

        after do
          I18n.locale = @old_locale
        end

        it { is_expected.to include 'label' => 'Title Alternative' }
        it { is_expected.to include 'value' => ['Another Title to the Work'] }
      end
    end

    context 'when a field is empty' do
      it 'does not appear in the output' do
        expect(presenter.title).to eq []
        expect(presenter.manifest_metadata.any? { |m| m['label'] == 'Title' }).to be false
      end
    end

    # I'm not entirely sure when this is being used (maybe we're passing work presenters
    # into this presenter; those return CV tuples), but we should make sure the presenter
    # knows how to handle a special-case controlled vocabulary value
    context 'when a field returns a controlled vocabulary tuple' do
      let(:subject_tuple) { [['http://id.worldcat.org/fast/2004076', 'Little free libraries']] }

      before do
        allow(Hyrax.config).to receive(:iiif_metadata_fields).and_return([:subject])
        allow(document).to receive(:subject).and_return(subject_tuple)
      end

      it { is_expected.to include 'label' => 'Subject' }
      it { is_expected.to include 'value' => ['Little free libraries'] }
    end
  end
end
