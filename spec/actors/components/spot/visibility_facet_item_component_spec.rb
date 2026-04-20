# frozen_string_literal: true

RSpec.describe Spot::VisibilityFacetItemComponent, type: :component do
  subject(:rendered) { Capybara::Node::Simple.new(rendered_html.to_s) }
  let(:rendered_html) { render_inline(described_class.new(facet_item: facet_item)) }
  let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }

  let(:facet_item) do
    instance_double(
      Blacklight::FacetItemPresenter,
      facet_config: Blacklight::Configuration::FacetField.new,
      label: visibility,
      hits: 10,
      href: '/catalog?f=x',
      selected?: false
    )
  end


  it 'renders the value as a PermissionBadge' do
    expect(rendered).to have_selector 'li'
    expect(rendered).to have_selector 'a.facet-select.badge.badge-danger'
    expect(rendered).to have_text 'Private'
  end
end
