# frozen_string_literal: true
RSpec.describe Spot::Renderers::ExternalAuthorityAttributeRenderer do
  let(:field) { :creator }
  let(:options) { {} }
  let(:renderer) { described_class.new(field, values, options) }
  let(:values) { [['https://www.carlyraemusic.com/', 'Carly Rae Jepsen']] }
  let(:helpers) { Rails.application.routes.url_helpers }

  describe '#attribute_to_html' do
    subject { Nokogiri::HTML(renderer.render) }

    let(:expected) { Nokogiri::HTML(html_result) }
    let(:search_path) do
      helpers.search_catalog_path('f[creator_sim][]': 'Carly Rae Jepsen', locale: I18n.locale)
    end

    let(:html_result) do
      '<tr><th rowspan="1">Creator</th>' \
      '<td itemprop="creator" itemscope itemtype="http://schema.org/Person" class="attribute attribute-creator">' \
      '<span itemprop="name">' \
      "<a href=\"#{search_path}\">Carly Rae Jepsen</a> (" \
        '<a target="_blank" href="https://www.carlyraemusic.com/">' \
        'view authority <span class="fa fa-external-link"></span>' \
      '</a>)</span></td></tr>'
    end

    it { is_expected.to be_equivalent_to expected }
  end
end
