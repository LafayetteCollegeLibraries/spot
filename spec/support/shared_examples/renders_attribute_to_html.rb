# frozen_string_literal: true
RSpec.shared_examples 'it renders an attribute to HTML' do
  let(:presenter) { described_class.new(SolrDocument.new(work.to_solr), ability) }
  let(:work_klass) { described_class.name.split('::').last.gsub(/Presenter$/, '').downcase.to_sym }
  let(:work) { build(work_klass) }
  let(:ability) { Ability.new(build(:user)) }
  let(:field) { :keyword }
  let(:options) { {} }

  describe '#attribute_to_html' do
    subject(:render_attribute!) { presenter.attribute_to_html(field, options) }

    let(:attribute_double) { instance_double(klass.to_s, render: true) }

    before do
      allow(klass).to receive(:new).and_return(attribute_double)
    end

    context 'default mode' do
      let(:klass) { Spot::Renderers::AttributeRenderer }

      it 'calls the AttributeRenderer by default' do
        render_attribute!

        expect(attribute_double).to have_received(:render)
      end
    end

    context 'when :faceted' do
      let(:klass) { Spot::Renderers::FacetedAttributeRenderer }
      let(:options) { { render_as: :faceted } }

      it 'calls the FacetedAttributeRenderer' do
        render_attribute!

        expect(attribute_double).to have_received(:render)
      end
    end

    context 'when :external_authority' do
      let(:klass) { Spot::Renderers::ExternalAuthorityAttributeRenderer }
      let(:options) { { render_as: :external_authority } }

      it 'calls the ExternalAuthorityAttributeRenderer' do
        render_attribute!

        expect(attribute_double).to have_received(:render)
      end
    end

    context 'when a Hyrax renderer is provided' do
      let(:klass) { Hyrax::Renderers::DateAttributeRenderer }
      let(:options) { { render_as: :date } }

      it 'calls the Hyrax DateAttributeRenderer' do
        render_attribute!

        expect(attribute_double).to have_received(:render)
      end
    end
  end
end
