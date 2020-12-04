# frozen_string_literal: true
RSpec.describe Spot::CollectionHelper, type: :helper do
  describe '.collection_banner_file_path' do
    subject { helper.collection_banner_file_path(presenter) }

    let(:presenter) { instance_double(Spot::CollectionPresenter, banner_file: banner_file) }

    context 'when a banner_file is present' do
      let(:banner_file) { '/branding/abc123def/banner/banner-file.jpg' }

      it { is_expected.to eq banner_file }
    end

    context 'when banner_file is not present' do
      let(:banner_file) { nil }

      # using #match instead of #eq since assets get a generated hash appended
      it { is_expected.to match(/\A\/assets\/default-collection-background-[a-z0-9]+.jpg\Z/) }
    end
  end

  describe '.render_related_resource_language' do
    subject(:rendered_language) { helper.render_related_resource_language(presenter) }

    let(:presenter) { instance_double(Spot::CollectionPresenter, related_resource: related_resource) }
    let(:link_html) { related_resource.map { |url| helper.link_to(url, url, target: '_blank').html_safe }.to_sentence }
    let(:expected_text) { I18n.t(translation_key, link_html: link_html) }

    context 'when empty' do
      let(:related_resource) { [] }

      it { is_expected.to be_nil }
    end

    context 'when one related resource exists' do
      let(:related_resource) { ['http://cool-resource.org/this/thing'] }
      let(:translation_key) { 'spot.collections.show.related_resource_single' }

      it { is_expected.to eq expected_text }
    end

    context 'when multiple related resources exist' do
      let(:related_resource) { ['http://cool-resource.org/this/thing', 'http://another-resource.org/that/thing'] }
      let(:translation_key) { 'spot.collections.show.related_resource_multiple' }

      it { is_expected.to eq expected_text }
    end
  end
end
