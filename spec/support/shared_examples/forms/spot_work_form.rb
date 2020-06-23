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

  describe '.model_attributes' do
    subject(:attributes) { described_class.model_attributes(form_params) }

    let(:form_params) { ActionController::Parameters.new(raw_params) }
    let(:raw_params) { {} }

    describe '(rights_statement)' do
      subject { attributes['rights_statement'] }

      let(:raw_params) { { 'rights_statement' => 'http://rightsstatements.org/vocab/NoC-OKLR/1.0/' } }

      it { is_expected.to eq [ActiveTriples::Resource.new('http://rightsstatements.org/vocab/NoC-OKLR/1.0/')] }
    end
  end

  describe '#rights_statement' do
    subject(:rights) { form.rights_statement }

    let(:form) { described_class.new(work, ability, nil) }
    let(:work) { build(work_klass) }
    let(:work_klass) { described_class.name.split('::').last.gsub(/Form$/, '').downcase.to_sym }
    let(:ability) { Ability.new(build(:admin_user)) }

    it 'transforms the values into strings' do
      expect(rights.all? { |v| v.is_a? String }).to be true
    end
  end
end
