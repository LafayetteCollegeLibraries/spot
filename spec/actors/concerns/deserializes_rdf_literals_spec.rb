# frozen_string_literal: true
RSpec.describe DeserializesRdfLiterals do
  before do
    class WorkType < ActiveFedora::Base
      property :title, predicate: ::RDF::Vocab::DC.title, multiple: false
      property :description, predicate: ::RDF::Vocab::DC.description
    end

    # need to define this to be able to access the `language_tagged_fields` array
    class Hyrax::WorkTypeForm < Hyrax::Forms::WorkForm
      include LanguageTaggedFormFields
      transforms_language_tags_for :title, :description
    end

    class WorkTypeActor < Hyrax::Actors::AbstractActor
      include DeserializesRdfLiterals
    end
  end

  after do
    Object.send(:remove_const, :WorkType)
    Object.send(:remove_const, :WorkTypeActor)
    Hyrax.send(:remove_const, :WorkTypeForm)
  end

  let(:work) { WorkType.new }
  let(:ability) { Ability.new(build(:user)) }
  let(:attributes) { {} }
  let(:env) { Hyrax::Actors::Environment.new(work, ability, attributes) }
  let(:actor) { WorkTypeActor.new(Hyrax::Actors::Terminator.new) }

  # when the actor receives the form attributes, it should have already
  # been run through the serializer
  let(:attributes) do
    {
      title: '"Cool Beans"@en',
      description: ['"A work of importance"']
    }
  end

  let(:literal_attributes) do
    {
      title: RDF::Literal('Cool Beans', language: :en),
      description: [RDF::Literal('A work of importance')]
    }
  end

  shared_examples 'it transforms fields' do
    it 'transforms single fields' do
      expect(env.attributes[:title]).to eq RDF::Literal('Cool Beans', language: :en)
    end

    it 'transforms multiple fields' do
      expect(env.attributes[:description]).to eq [RDF::Literal('A work of importance')]
    end
  end

  describe '#create' do
    before { actor.create(env) }

    it_behaves_like 'it transforms fields'

    context 'when attributes are already RDF::Literals (from ingest)' do
      let(:attributes) { literal_attributes }

      it_behaves_like 'it transforms fields'
    end
  end

  describe '#update' do
    before { actor.update(env) }

    it_behaves_like 'it transforms fields'

    context 'when attributes are already RDF::Literals (from ingest)' do
      let(:attributes) { literal_attributes }

      it_behaves_like 'it transforms fields'
    end
  end
end
