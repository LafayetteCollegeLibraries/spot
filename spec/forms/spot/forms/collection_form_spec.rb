# frozen_string_literal: true
RSpec.describe Spot::Forms::CollectionForm do
  subject(:form) { described_class.new(Collection.new, Ability.new(user), nil) }

  let(:user) { build(:admin_user) }
  let(:hyrax_fields) { %i[visibility representative_id collection_type_gid thumbnail_id] }

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
    it { is_expected.to include :location }
    it { is_expected.to include :related_resource }
    it { is_expected.to include :sponsor }

    # hyrax jawns
    it { is_expected.to include(*hyrax_fields) }
  end

  describe '.singular_fields' do
    subject { described_class.singular_fields }

    let(:fields) { %i[title abstract description] }

    it { is_expected.to contain_exactly(*(fields + hyrax_fields)) }
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
    it { is_expected.to include(location_attributes: [:id, :_destroy]) }
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
      let(:field) { :location }

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

  describe 'singular form fields' do
    described_class.singular_fields.each do |field|
      context field.to_s do
        subject { form.send(field) }

        it { is_expected.not_to be_an Array }
      end
    end
  end

  describe '#primary_terms' do
    subject { form.primary_terms }

    let(:fields) { %i[visibility thumbnail_id representative_id collection_type_gid] }

    it { is_expected.not_to include(*fields) }
  end

  describe '#secondary_terms' do
    subject { form.secondary_terms }

    it { is_expected.to be_empty }
  end

  describe '.primary_terms form hints' do
    described_class.new(Collection.new, nil, nil).primary_terms.each do |term|
      describe "for #{term}" do
        subject do
          I18n.t("simple_form.hints.collection.#{term}",
                 locale: :en,
                 default: ["simple_form.hints.defaults.#{term}"])
        end

        it { is_expected.not_to be_nil, "Hint missing for Collection##{term}" }
      end
    end
  end
end
