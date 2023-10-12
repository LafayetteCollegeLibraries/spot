# frozen_string_literal: true
RSpec.describe Hyrax::AudioVisualForm do
  it_behaves_like 'a Spot work form'
  it_behaves_like 'it handles required fields', :title, :rights_statement

  describe '.terms' do
    subject { described_class.terms }

    describe 'includes optional fields' do
      it { is_expected.to include :date }
      it { is_expected.to include :embed_url }
    end
  end

  describe '.build_permitted_params' do
    subject { described_class.build_permitted_params }

    it { is_expected.to include(:title) }
    it { is_expected.to include(date: []) }
    it { is_expected.to include(:rights_statement) }
    it { is_expected.to include(:embed_url) }
  end

  describe '.multiple?' do
    it 'marks singular fields as false' do
      [:title, :rights_statement, :embed_url].each do |f|
        expect(described_class.multiple?(f)).to be false
      end
    end
  end
end
