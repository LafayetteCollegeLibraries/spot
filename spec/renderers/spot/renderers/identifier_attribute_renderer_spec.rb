# frozen_string_literal: true
RSpec.describe Spot::Renderers::IdentifierAttributeRenderer do
  let(:field) { :identifier }
  let(:renderer) { described_class.new(field, value) }

  describe '#render' do
    subject { Nokogiri::HTML(renderer.render) }

    let(:expected) { Nokogiri::HTML(html_result) }

    context 'when a prefix is present' do
      let(:value) { Spot::Identifier.from_string('isbn:978-1467715478') }

      let(:html_result) do
        '<tr><th rowspan="1">Standard Identifier</th>' \
        '<td class="attribute attribute-identifier">' \
        '<span class="label label-default">ISBN</span> ' \
        '978-1467715478</td></tr>'
      end

      it { is_expected.to be_equivalent_to expected }
    end

    context 'when a prefix is not present' do
      let(:value) { Spot::Identifier.from_string('B0023882-01') }

      let(:html_result) do
        '<tr><th rowspan="1">Standard Identifier</th>' \
        '<td class="attribute attribute-identifier">B0023882-01</td></tr>'
      end

      it { is_expected.to be_equivalent_to expected }
    end
  end
end
