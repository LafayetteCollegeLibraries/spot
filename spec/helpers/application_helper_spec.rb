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

    # this is hacky, but the only time this class_variable should need to be different
    # is in a testing environment; otherwise we're not expecting it to change
    # while application is running
    before do
      ApplicationHelper.class_variable_set(:@@site_last_updated, nil) # rubocop:disable Style/ClassVars
    end

    context 'when $SPOT_BUILD_DATE is present and a date' do
      before do
        stub_env('SPOT_BUILD_DATE', '20230828')
      end

      it { is_expected.to eq 'August 28, 2023' }
    end

    context 'when $SPOT_BUILD_DATE is not a date' do
      before do
        stub_env('SPOT_BUILD_DATE', 'Late last night (or the night before)')
      end

      it { is_expected.to eq 'Late last night (or the night before)' }
    end

    context 'when $SPOT_BUILD_DATE is not present' do
      before do
        stub_env('SPOT_BUILD_DATE', '')
      end

      it { is_expected.to be nil }
    end
  end
end
