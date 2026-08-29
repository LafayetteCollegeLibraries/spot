# frozen_string_literal: true
RSpec.describe DeserializesRdfLiterals, :skip_if_valkyrie do
  before do
    class TestWorkType < ActiveFedora::Base
      property :title, predicate: ::RDF::Vocab::DC.title, multiple: false
      property :description, predicate: ::RDF::Vocab::DC.description
    end

    class TestWorkTypeActor < Hyrax::Actors::AbstractActor
      include DeserializesRdfLiterals
    end

    # This is all incredibly messy because the Actor mixin is relying on a class attribute
    # for a form based on naming conventions, hence this silly unused Form class and exposing
    # the test classes to the Object namespace (as opposed to `let(:work_type_class) { Class.new(ActiveFedora::Base) }`)
    class Hyrax::TestWorkTypeForm < ::Spot::Forms::WorkForm
      include LanguageTaggedFormFields
      transforms_language_tags_for :title, :description
    end
  end

  after do
    Object.send(:remove_const, :TestWorkType)
    Object.send(:remove_const, :TestWorkTypeActor)
    Hyrax.send(:remove_const, :TestWorkTypeForm)
  end

  let(:work) { TestWorkType.new }
  let(:ability) { Ability.new(create(:user)) }
  let(:actor) { TestWorkTypeActor.new(Hyrax::Actors::Terminator.new) }

  # when the actor receives the form attributes, it should have already
  # been run through the serializer
  let(:string_attributes) do
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

  describe '#create' do
    context 'with string values' do
      let(:env) { Hyrax::Actors::Environment.new(work, ability, string_attributes) }

      it 'transforms single fields' do
        expect { actor.create(env) }
          .to change { env.attributes[:title] }
          .from(string_attributes[:title])
          .to(literal_attributes[:title])
      end

      it 'transforms multiple fields' do
        expect { actor.create(env) }
          .to change { env.attributes[:title] }
          .from(string_attributes[:title])
          .to(literal_attributes[:title])
      end
    end

    context 'with literal values' do
      let(:env) { Hyrax::Actors::Environment.new(work, ability, literal_attributes) }

      it 'transforms single fields' do
        expect { actor.create(env) }
          .not_to change { env.attributes[:title] }
      end

      it 'transforms multiple fields' do
        expect { actor.create(env) }
          .not_to change { env.attributes[:title] }
      end
    end
  end

  describe '#update' do
    context 'with string values' do
      let(:env) { Hyrax::Actors::Environment.new(work, ability, string_attributes) }

      it 'transforms single fields' do
        expect { actor.update(env) }
          .to change { env.attributes[:title] }
          .from(string_attributes[:title])
          .to(literal_attributes[:title])
      end

      it 'transforms multiple fields' do
        expect { actor.update(env) }
          .to change { env.attributes[:title] }
          .from(string_attributes[:title])
          .to(literal_attributes[:title])
      end
    end

    context 'with literal values' do
      let(:env) { Hyrax::Actors::Environment.new(work, ability, literal_attributes) }

      it 'transforms single fields' do
        expect { actor.update(env) }
          .not_to change { env.attributes[:title] }
      end

      it 'transforms multiple fields' do
        expect { actor.update(env) }
          .not_to change { env.attributes[:title] }
      end
    end
  end
end
