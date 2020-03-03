# frozen_string_literal: true
RSpec.shared_examples 'a Spot work form' do
  it_behaves_like 'it strips whitespaces from values'
  it_behaves_like 'it handles identifier form fields'
  it_behaves_like 'it has hints for all primary_terms'

  describe '.terms' do
    subject(:terms) { described_class.terms }

    it 'includes internal_form_fields' do
      expect(terms).to include(*described_class.hyrax_form_fields)
    end
  end
end
