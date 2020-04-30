# frozen_string_literal: true
RSpec.describe Spot::Renderers::AttributeRenderer do
  let(:field) { :title }
  let(:options) { {} }
  let(:renderer) { described_class.new(field, values, options) }
  let(:values) { 'Run Away With Me' }

  describe '#render' do
    subject { Nokogiri::HTML(renderer.render) }

    let(:expected) { Nokogiri::HTML(html_result) }

    context 'when a single value' do
      let(:values) { 'Emotion' }

      let(:html_result) do
        '<tr><th rowspan="1">Title</th>' \
        '<td class="attribute attribute-title">' \
        '<span itemprop="name">Emotion</span>' \
        '</td></tr>'
      end

      it { is_expected.to be_equivalent_to expected }
    end

    context 'when multiple values' do
      let(:values) { ['Party for One', 'Cut to the Feeling'] }

      let(:html_result) do
        '<tr><th rowspan="2">Title</th>' \
        '<td class="attribute attribute-title">' \
        '<span itemprop="name">Party for One</span>' \
        '</td></tr>' \
        '<tr><td class="attribute attribute-title">' \
        '<span itemprop="name">Cut to the Feeling</span>' \
        '</td></tr>'
      end

      it { is_expected.to be_equivalent_to expected }
    end

    context 'when no microdata is available' do
      before do
        allow(renderer)
          .to receive(:microdata_value_attributes)
          .and_return({})
      end

      let(:html_result) do
        '<tr><th rowspan="1">Title</th>' \
        '<td class="attribute attribute-title">Run Away With Me</td></tr>'
      end

      it { is_expected.to be_equivalent_to expected }
    end

    context 'options[:show_help_text]' do
      before do
        allow(I18n).to receive(:translate)
          .with(:'simple_form.hints.defaults.title', default: [], raise: true)
          .and_return(help_text)
        allow(I18n).to receive(:translate)
          .with(:'blacklight.search.fields.default.show.title', raise: true)
          .and_return('Title')
      end

      let(:help_text) { 'Stuck in my head, stuck in my heart, stuck in my body (body)' }
      let(:options) { { show_help_text: true } }

      let(:html_result) do
        %(<tr>
          <th rowspan="1">Title
            <span
              class="fa fa-question-circle-o"
              data-html="true"
              data-toggle="popover"
              data-trigger="hover click"
              data-content="#{help_text}"
            ></span>
          </th>
          <td class="attribute attribute-title">
            <span itemprop="name">Run Away With Me</span>
          </td>
        </tr>)
      end

      it { is_expected.to be_equivalent_to expected }
    end
  end
end
