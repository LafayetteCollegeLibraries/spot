# frozen_string_literal: true
RSpec.describe Spot::Renderers::IdentifierAttributeRenderer do
  let(:field) { :identifier }
  let(:renderer) { described_class.new(field, value, opts) }
  let(:opts) { {} }
  let(:standard_value) { Spot::Identifier.from_string('isbn:978-1467715478') }
  let(:local_value) { Spot::Identifier.from_string('B0023882-01') }

  describe '#render' do
    subject { Nokogiri::HTML(renderer.render) }

    let(:value) { standard_value }
    let(:expected) { Nokogiri::HTML(html_result) }

    context 'when a prefix is present' do
      let(:html_result) do
        '<tr><th rowspan="1">Standard Identifier</th>' \
        '<td class="attribute attribute-identifier">' \
        '<span class="label label-default">ISBN</span> ' \
        '978-1467715478</td></tr>'
      end

      it { is_expected.to be_equivalent_to expected }
    end

    context 'when a prefix is not present' do
      let(:value) { local_value }
      let(:html_result) do
        '<tr><th rowspan="1">Standard Identifier</th>' \
        '<td class="attribute attribute-identifier">B0023882-01</td></tr>'
      end

      it { is_expected.to be_equivalent_to expected }
    end

    context 'when asked to render as `local: true`' do
      let(:value) { standard_value }
      let(:opts) { { local: true } }

      let(:html_result) do
        '<tr><th rowspan="1">Standard Identifier</th>' \
        '<td class="attribute attribute-identifier">' \
        '<code>isbn:978-1467715478</code></td></tr>'
      end

      it { is_expected.to be_equivalent_to expected }
    end
  end
end
