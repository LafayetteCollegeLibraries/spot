# frozen_string_literal: true
RSpec.shared_examples 'a Spot work form' do
  it_behaves_like 'it strips whitespaces from values'
  it_behaves_like 'it handles identifier form fields'
  it_behaves_like 'it has hints for all primary_terms'
  it_behaves_like 'it builds Hyrax permitted params'

  describe '.terms' do
    subject(:terms) { described_class.terms }

    it 'includes internal_form_fields' do
      expect(terms).to include(*described_class.hyrax_form_fields)
    end
  end

  describe '#rights_statement' do
    subject(:rights) { form.rights_statement }

    let(:form) { described_class.new(work, ability, nil) }
    let(:work) { build(work_klass.underscore.to_sym) }
    let(:work_klass) { described_class.name.split('::').last.gsub(/Form$/, '') }
    let(:ability) { Ability.new(build(:admin_user)) }

    it 'transforms the values into strings' do
      if form.multiple?('rights_statement')
        expect(rights.all? { |v| v.is_a? String }).to be true
      else
        expect(rights).to be_a String
      end
    end

    context 'when no rights_statement present' do
      let(:work) { work_klass.constantize.new }

      it do
        if form.multiple?('rights_statement')
          expect(rights).to eq []
        else
          expect(rights).to eq ''
        end
      end
    end
  end
end
