# frozen_string_literal: true
RSpec.describe Spot::Forms::CollectionForm do
  subject(:form) { described_class.new(Collection.new, Ability.new(user), nil) }

  let(:user) { build(:admin_user) }

  shared_context 'required fields' do
    it 'contains required fields' do
      expect(terms).to include :title
    end
  end

  describe '.required_fields' do
    subject(:terms) { described_class.required_fields }

    include_context 'required fields'
  end

  describe '.terms' do
    subject(:terms) { described_class.terms }

    include_context 'required fields'

    it { is_expected.to include :abstract }
    it { is_expected.to include :description }
    it { is_expected.to include :identifier }
    it { is_expected.to include :language }
    it { is_expected.to include :place }
    it { is_expected.to include :related_resource }
    it { is_expected.to include :sponsor }

    # hyrax jawns
    it { is_expected.to include :visibility }
    it { is_expected.to include :representative_id }
    it { is_expected.to include :collection_type_gid }
    it { is_expected.to include :thumbnail_id }
  end

  describe '.singular_fields' do
    subject { described_class.singular_fields }

    let(:fields) { %i[title abstract description] }

    it { is_expected.to contain_exactly(*fields) }
  end

  describe '.multiple?' do
    it 'marks singular fields as false' do
      expect(described_class.singular_fields.all? { |f| !described_class.multiple?(f) }).to be true
    end
  end

  describe '.build_permitted_params' do
    subject { described_class.build_permitted_params }

    it { is_expected.to be_an Array }
    it { is_expected.to include :thumbnail_id }
    it { is_expected.to include(place_attributes: [:id, :_destroy]) }
  end

  describe '.model_attributes' do
    subject(:attributes) { described_class.model_attributes(raw_params) }

    let(:raw_params) { ActionController::Parameters.new(params) }

    describe 'pluralizes singular fields' do
      subject { attributes[field] }

      let(:params) { { field => value } }

      context 'title' do
        let(:field) { :title }
        let(:value) { 'a cool title' }

        it { is_expected.to eq [value] }
      end

      context 'abstract' do
        let(:field) { :abstract }
        let(:value) { 'a short description of the collection' }

        it { is_expected.to eq [value] }
      end

      context 'description' do
        let(:field) { :description }
        let(:value) { 'a longer description of the collection with more information' }

        it { is_expected.to eq [value] }
      end
    end
  end

  describe '#initialize_field' do
    subject { form.initialize_field(field) }

    context 'when a controlled property' do
      let(:field) { :place }

      it { is_expected.to include Spot::ControlledVocabularies::Location }
    end

    context 'when a multiple property' do
      let(:field) { :identifier }

      it { is_expected.to eq [''] }
    end

    context 'when a singular property' do
      let(:field) { :title }

      it { is_expected.to eq '' }
    end
  end
end
