# frozen_string_literal: true
RSpec.describe MultiAuthorityControlledVocabularyInput, type: :input do
  let(:work) { build(:publication) }
  let(:form) { Hyrax::PublicationForm.new(work, admin_ability, nil) }
  let(:admin_ability) { Ability.new(create(:admin_user)) }
  let(:input) { input_for(form, :location, as: :multi_authority_controlled_vocabulary, authorities: [:geonames, :tgn]) }

  let(:item1) { double('value 1', rdf_label: ['Item 1'], rdf_subject: 'http://example.org/1', node?: false) }
  let(:item2) { double('value 2', rdf_label: ['Item 2'], rdf_subject: 'http://example.org/2', node?: false) }

  before do
    allow(form).to receive(:[]).with(:location).and_return([item1, item2])
  end

  it 'adds dropdowns for each authority' do
    expect(input).to have_selector('select#publication_location_authority_select_2 option', count: 3)
  end

  it 'renders label + subject if both are present' do
    expect(input).to have_selector('input[value="Item 1 (http://example.org/1)"]', visible: false)
    expect(input).to have_selector('input[value="Item 2 (http://example.org/2)"]', visible: false)
  end
end
