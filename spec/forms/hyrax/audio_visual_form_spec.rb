# frozen_string_literal: true
RSpec.describe Hyrax::ImageForm do
  it_behaves_like 'a Spot work form'
  it_behaves_like 'it handles required fields', :title, :rights_statement

  describe '.terms' do
    subject(:terms) { described_class.terms }

    describe 'includes optional fields' do
      it { is_expected.to include :date }
      it { is_expected.to include :premade_derivatives }
    end
  end

  describe '.build_permitted_params' do
    subject(:params) { described_class.build_permitted_params }

    it { is_expected.to include(:title) }
    it { is_expected.to include(date: []) }
    it { is_expected.to include(:rights_statement) }
    it { is_expected.to include(premade_derivatives: []) }
  end
end
