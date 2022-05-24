# frozen_string_literal: true
RSpec.describe Spot::Forms::CollectionForm do
  subject(:form) { described_class.new(collection, Ability.new(user), nil) }

  let(:collection) { Collection.new }
  let(:user) { build(:admin_user) }
  let(:hyrax_fields) { %i[visibility collection_type_gid] }

  it_behaves_like 'it handles identifier form fields'
  it_behaves_like 'it handles required fields', :title

  # need to change the field being tested here, as Collections
  # don't use :resource_type
  #
  # @see spec/support/shared_examples/forms/strips_whitespace.rb
  it_behaves_like 'it strips whitespaces from values' do
    let(:field) { :sponsor }
  end

  describe '.terms' do
    subject(:terms) { described_class.terms }

    it { is_expected.to include :abstract }
    it { is_expected.to include :description }
    it { is_expected.to include :standard_identifier }
    it { is_expected.to include :local_identifier }
    it { is_expected.to include :language }
    it { is_expected.to include :location }
    it { is_expected.to include :related_resource }
    it { is_expected.to include :slug }
    it { is_expected.to include :sponsor }

    # hyrax jawns
    it { is_expected.to include(*hyrax_fields) }
  end

  describe '.multiple?' do
    let(:singular_fields) { [:title, :abstract, :description] }

    it 'marks singular fields as false' do
      expect(singular_fields.all? { |f| !described_class.multiple?(f) }).to be true
    end
  end

  describe '.build_permitted_params' do
    subject { described_class.build_permitted_params }

    it { is_expected.to be_an Array }
    it { is_expected.to include(location_attributes: [:id, :_destroy]) }
    it { is_expected.to include :slug }
  end

  describe '.model_attributes' do
    subject(:attributes) { described_class.model_attributes(raw_params) }

    let(:raw_params) { ActionController::Parameters.new(params) }

    describe 'pluralizes + literalizes language-tagged fields' do
      subject { attributes[field] }

      context 'title' do
        let(:field) { :title }
        let(:params) do
          { 'title_value' => 'A Collection', 'title_language' => 'en' }
        end

        it { is_expected.to eq [RDF::Literal('A Collection', language: :en)] }
      end

      context 'abstract' do
        let(:field) { :abstract }
        let(:params) do
          { 'abstract_value' => 'A shorter description of a collection',
            'abstract_language' => 'en' }
        end

        it { is_expected.to eq [RDF::Literal('A shorter description of a collection', language: :en)] }
      end

      context 'description' do
        let(:field) { :description }
        let(:params) do
          { 'description_value' => 'A lengthier explanation of a collection',
            'description_language' => 'en' }
        end

        it { is_expected.to eq [RDF::Literal('A lengthier explanation of a collection', language: :en)] }
      end
    end

    describe 'stores a "slug" identifier' do
      subject { attributes[:identifier] }

      let(:params) { { 'slug' => 'a-cool-collection' } }

      it { is_expected.to include 'slug:a-cool-collection' }
    end
  end

  describe '#initialize_field' do
    subject { form.initialize_field(field) }

    context 'when a controlled property' do
      let(:field) { :location }

      it { is_expected.to include Spot::ControlledVocabularies::Location }
    end

    context 'when a multiple property' do
      let(:field) { :sponsor }

      it { is_expected.to eq [''] }
    end

    context 'when a singular property' do
      let(:field) { :title }

      it { is_expected.to eq '' }
    end
  end

  describe '#local_identifier' do
    subject { form.local_identifier }

    let(:collection) { Collection.new(identifier: ['local:abc123', 'slug:a-cool-collection']) }

    it { is_expected.not_to include 'slug:a-cool-collection' }
  end

  describe '#primary_terms' do
    subject { form.primary_terms }

    let(:fields) { %i[visibility representative_id collection_type_gid] }

    it { is_expected.not_to include(*fields) }
  end

  describe '#secondary_terms' do
    subject { form.secondary_terms }

    it { is_expected.to be_empty }
  end

  describe '#slug' do
    subject { form.slug }

    let(:collection) { Collection.new(metadata) }

    context 'when no slug: identifier exists' do
      let(:metadata) { {} }

      it { is_expected.to be nil }
    end

    context 'when a slug: identifier exists' do
      let(:metadata) { { identifier: ['slug:cool-collection'] } }

      it { is_expected.to eq 'cool-collection' }
    end
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
