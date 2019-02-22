# frozen_string_literal: true
RSpec.describe Spot::Renderers::FacetedAttributeRenderer do
  let(:field) { :keyword }
  let(:value) { 'emotion' }
  let(:options) { {} }
  let(:renderer) { described_class.new(field, value, options) }
  let(:helpers) { Rails.application.routes.url_helpers }
  let(:html_result) do
    '<tr><th rowspan="1">Keyword</th>' \
    '<td class="attribute attribute-keyword">' \
    '<span itemprop="keywords">' \
    "<a href=\"#{url}\">emotion</a>" \
    '</span></td></tr>'
  end
  let(:url) { helpers.search_catalog_path("f[#{search_field}][]": value, locale: I18n.locale) }

  describe '#render' do
    subject { Nokogiri::HTML(renderer.render) }

    let(:expected) { Nokogiri::HTML(html_result) }

    context 'when no search field is provided' do
      let(:search_field) { :keyword_sim }

      it { is_expected.to be_equivalent_to expected }
    end

    context 'when a search field is provided' do
      let(:search_field) { :keyword_ssim }
      let(:options) { { search_field: search_field } }

      it { is_expected.to be_equivalent_to expected }
    end
  end
end
