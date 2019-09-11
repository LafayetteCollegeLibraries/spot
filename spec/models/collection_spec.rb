# frozen_string_literal: true
RSpec.describe Collection do
  let(:collection) { described_class.new(params) }
  let(:dc) { RDF::Vocab::DC }
  let(:rdfs) { RDF::RDFS }
  let(:schema) { RDF::Vocab::SCHEMA }
  let(:params) { base_params }
  let(:base_params) { { title: ['ok'], collection_type_gid: collection_type_gid } }
  let(:collection_type) { Hyrax::CollectionType.find_or_create_by(title: 'a cool collection type') }
  let(:collection_type_gid) { collection_type.gid }

  it_behaves_like 'a model with hyrax core metadata'

  it { is_expected.to have_editable_property(:abstract).with_predicate(dc.abstract) }
  it { is_expected.to have_editable_property(:description).with_predicate(dc.description) }
  it { is_expected.to have_editable_property(:subject).with_predicate(dc.subject) }
  it { is_expected.to have_editable_property(:identifier).with_predicate(dc.identifier) }
  it { is_expected.to have_editable_property(:related_resource).with_predicate(rdfs.seeAlso) }
  it { is_expected.to have_editable_property(:location).with_predicate(dc.spatial) }
  it { is_expected.to have_editable_property(:sponsor).with_predicate(schema.sponsor) }

  describe '#to_param' do
    subject { collection.to_param }

    context 'when a slug identifier is present' do
      let(:params) { base_params.merge(identifier: ["slug:#{slug}"]) }
      let(:slug) { 'a-good-collection' }

      it { is_expected.to eq slug }
    end

    context 'when a slug identifier is not present' do
      it { is_expected.to eq collection.id }
    end
  end

  describe 'validates OnlyUrlsValidator for :related_resource' do
    subject { collection.errors }

    before { collection.validate }

    let(:url) { 'https://lafayette.edu' }

    context 'when passed a url' do
      let(:params) { base_params.merge(related_resource: [url]) }

      it { is_expected.to be_empty }
    end

    context 'when passed something else' do
      let(:params) { base_params.merge(related_resource: ['lolol', url]) }

      it { is_expected.not_to be_empty }
    end
  end

  describe 'validates SlugValidator for :identifier' do
    subject { collection.errors }

    before { collection.validate }

    context 'when no identifiers present' do
      it { is_expected.to be_empty }
    end

    context 'when one slug is present' do
      let(:params) { base_params.merge(identifier: ['slug:example-collection']) }

      it { is_expected.to be_empty }
    end

    context 'when identifiers are present, but no slugs' do
      let(:params) { base_params.merge(identifier: ['issn:1234-5678']) }

      it { is_expected.to be_empty }
    end

    context 'when multiple slugs are present' do
      let(:params) { base_params.merge(identifier: ['slug:example-collection', 'slug:another-one']) }

      it { is_expected.not_to be_empty }
    end

    context 'when a slug has invalid characters' do
      let(:params) { base_params.merge(identifier: ['slug:inv@a!d_slug']) }

      it { is_expected.not_to be_empty }
    end
  end
end
