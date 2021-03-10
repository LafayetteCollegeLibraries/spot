# frozen_string_literal: true
RSpec.describe Spot::CatalogHelper, type: :helper do
  describe '#humanize_edtf_values' do
    subject { helper.humanize_edtf_values(args) }
    let(:args) { { value: value } }

    context 'when a value is parseable by Date.edtf' do
      let(:value) { ['1912-06-01/2002-08-10'] }

      it { is_expected.to eq 'June 1, 1912 to August 10, 2002' }
    end

    context 'when a value is not parseable by Date.edtf' do
      let(:value) { ['unparseable'] }

      it { is_expected.to eq 'unparseable' }
    end
  end

  describe 'visibility helpers' do
    let(:document) { SolrDocument.new(solr_data) }
    let(:solr_data) { {} }
    let(:embargo_solr_data) { { embargo_release_date_dtsi: '2021-02-26T00:00:00Z' } }
    let(:lease_solr_data) { { lease_expiration_date_dtsi: '2021-02-26T00:00:00Z' } }
    let(:authenticated_solr_data) { { read_access_group_ssim: [Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED] } }
    let(:metadata_solr_data) do
      { visibility_ssi: 'metadata',
        discover_access_group_ssim: [Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC] }
    end

    describe '#display_info_alert?' do
      subject { helper.display_info_alert?(document) }

      context 'when the doc has an embargo release date' do
        let(:solr_data) { embargo_solr_data }

        it { is_expected.to be true }
      end

      context 'when the doc has a lease expiration date' do
        let(:solr_data) { lease_solr_data }

        it { is_expected.to be true }
      end

      context 'when the doc requires authenticated access' do
        let(:solr_data) { authenticated_solr_data }

        it { is_expected.to be true }
      end

      context 'when the doc is metadata only' do
        let(:solr_data) { metadata_solr_data }
        it { is_expected.to be true }
      end

      context 'by default' do
        it { is_expected.to be false }
      end
    end

    describe '#document_access_display_text' do
      subject { helper.document_access_display_text(document) }

      context 'when an embargo release date is present' do
        let(:solr_data) { embargo_solr_data }

        it { is_expected.to eq I18n.t('spot.work.access_message.embargo_html', date: 'February 26, 2021') }
      end

      context 'when a lease expiration date is present' do
        let(:solr_data) { lease_solr_data }

        it { is_expected.to eq I18n.t('spot.work.access_message.lease_html', date: 'February 26, 2021') }
      end

      context 'when the doc requires authenticated access' do
        let(:solr_data) { authenticated_solr_data }

        it { is_expected.to eq I18n.t('spot.work.access_message.authenticated_html') }
      end

      context 'when the doc is metadata_only' do
        let(:solr_data) { metadata_solr_data }

        it { is_expected.to eq I18n.t('spot.work.access_message.metadata_html') }
      end

      context 'the default behavior' do
        it { is_expected.to eq I18n.t('spot.work.access_message.default_html') }
      end
    end
  end
end
