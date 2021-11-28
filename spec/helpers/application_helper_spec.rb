# frozen_string_literal: true
RSpec.describe ApplicationHelper do
  describe '#browse_collections_path' do
    subject { helper.browse_collections_path }

    it { is_expected.to eq '/catalog?f%5Bhas_model_ssim%5D%5B%5D=Collection' }
  end

  describe '#extracted_text_highlight_values_for' do
    subject { helper.extracted_text_highlight_values_for(document) }

    let(:document) { SolrDocument.new({ 'id' => 'abc123def' }, solr_response) }

    context 'when a document has highlight values' do
      let(:solr_response) do
        {
          'highlighting' => {
            'abc123def' => {
              'extracted_text_tsimv' => [
                '<em>I am a match</em>',
                '<em>So am I</em>'
              ]
            }
          }
        }
      end
      let(:expected_values) do
        [
          '<em>I am a match</em>'.html_safe,
          '<em>So am I</em>'.html_safe
        ]
      end

      it { is_expected.to eq expected_values }
    end

    context 'when a document has no highlight values' do
      let(:solr_response) { {} }

      it { is_expected.to eq [] }
    end
  end

  describe '#site_last_updated' do
    subject { helper.site_last_updated }

    before do
      allow(Rails.env).to receive(:production?).and_return(production_env)
    end

    context 'when in production' do
      before do
        allow(Dir).to receive(:pwd).and_return(directory)
      end

      let(:production_env) { true }

      context 'when in a capistrano directory' do
        let(:directory) { '/var/www/spot/releases/20211125133725' }

        it { is_expected.to eq 'November 25, 2021' }
      end

      context 'when not in a capistrano directory' do
        before do
          allow(Time.zone).to receive(:now).and_return(date_mock)
          allow(date_mock)
            .to receive(:strftime)
            .with('%B %d, %Y')
            .and_return(expected_date)
        end

        let(:directory) { '/var/www/spot' }
        let(:date_mock) { instance_double('Date') }
        let(:expected_date) { 'November 29, 2021' }

        it { is_expected.to eq expected_date }
      end
    end

    context 'when in development' do
      let(:production_env) { false }

      it { is_expected.to eq 'Not in production environment' }
    end
  end
end
