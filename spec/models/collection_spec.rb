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

  describe '.find' do
    subject { described_class.find(param) }

    before { collection.save }
    after { collection.destroy(eradicate: true) }

    context 'when a slug' do
      let(:param) { 'cool-collection' }

      context 'when a collection with that slug exists' do
        let(:params) { base_params.merge(identifier: ["slug:#{param}"]) }

        it { is_expected.to eq collection }
      end

      context 'when the collection does not exist' do
        it 'raises an ObjectNotFoundError' do
          expect { described_class.find(param) }
            .to raise_error(ActiveFedora::ObjectNotFoundError, %r{'id'=#{param}$})
        end
      end

      context 'when the param is an id' do
        subject { described_class.find(param) }

        let(:param) { collection.id }

        it { is_expected.to eq collection }
      end
    end
  end

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

  # note: this should fail when we update to hyrax@3 because we'll need to stub +Hyrax.query_service+
  describe '#add_member_objects' do
    let(:grandparent_collection) { described_class.new(id: 'grandparent-collection') }
    let(:parent_collection) { described_class.new(id: 'parent-collection') }
    let(:child_collection) { described_class.new(id: 'child-collection') }
    let(:work) { Publication.new(id: 'publication-to-add-to-collections') }

    before do
      allow(work).to receive(:save!)
      allow(ActiveFedora::Base).to receive(:find).with(work.id).and_return(work)
    end

    context 'with no parent objects' do
      let(:col) { described_class.new(id: 'a-single-collection') }

      it 'adds the work to the collection' do
        expect(col.add_member_objects(work.id)).to eq [work]
        expect(work.member_of_collections).to eq [col]
      end
    end

    context 'with a single parent object' do
      before { child_collection.member_of_collections << parent_collection }

      it 'adds the work to the collection + parent' do
        expect(child_collection.add_member_objects(work.id)).to eq [work]
        expect(work.member_of_collections).to eq [child_collection, parent_collection]
      end
    end

    context 'with a deeper tree' do
      before do
        parent_collection.member_of_collections << grandparent_collection
        child_collection.member_of_collections << parent_collection
      end

      it 'adds the work to all of the collections downstream' do
        expect(child_collection.add_member_objects(work.id)).to eq [work]
        expect(work.member_of_collections).to eq [child_collection, parent_collection, grandparent_collection]
      end
    end

    context 'when the Hyrax.query_service is active' do
      let(:query_service) { double }

      before do
        allow(Hyrax).to receive(:query_service).and_return(query_service)
        allow(query_service)
          .to receive(:find_by_alternate_id)
          .with(alternate_id: work.id, use_valkyrie: false)
          .and_return(work)
      end

      it 'uses the service' do
        expect(child_collection.add_member_objects([work.id])).to eq [work]
        expect(query_service).to have_received(:find_by_alternate_id)
      end
    end

    context 'when a work can not be added to the collection' do
      let(:checker_double) { instance_double(Hyrax::MultipleMembershipChecker) }

      before do
        allow(Hyrax::MultipleMembershipChecker)
          .to receive(:new)
          .with(item: work)
          .and_return(checker_double)

        allow(checker_double)
          .to receive(:check)
          .with(collection_ids: [child_collection.id], include_current_members: true)
          .and_return('Can not include work into collection')
      end

      it 'returns works with errors attached' do
        expect(child_collection.add_member_objects([work.id]).flat_map { |work| work.errors[:collections] })
          .to eq ['Can not include work into collection']
      end
    end
  end
end
