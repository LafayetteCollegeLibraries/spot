# frozen_string_literal: true
RSpec.describe Hyrax::PublicationResourceForm do
  subject(:form) { described_class.new(resource) }

  let(:form_definitions) { form.class.definitions }
  let(:resource) { build(:publication_resource) }

  describe '#title' do
    let(:field) { :title }

    describe 'a language-tagged form field' do
      it 'adds a virtual #title_language property' do
        expect(form_definitions.keys).to include('title_language')
        expect(form_definitions['title_language'][:writeable]).to be false
        expect(form_definitions['title_language'][:readable]).to be false
      end

      it 'adds a virtual #title_value property' do
        expect(form_definitions.keys).to include('title_value')
        expect(form_definitions['title_value'][:writeable]).to be false
        expect(form_definitions['title_value'][:readable]).to be false
      end

      describe 'prepopulation' do
        let(:resource) { build(:publication_resource, title: [RDF::Literal('Resource Title', language: :eng)]) }

        it 'populates #title_value' do
          expect { form.prepopulate! }.to change { form.title_value }.from([]).to(['Resource Title'])
        end

        it 'populates #title_language' do
          expect { form.prepopulate! }.to change { form.title_language }.from([]).to(['eng'])
        end
      end

      describe 'RDF Literal builder validation' do
        let(:resource) { build(:publication_resource, title: []) }
        let(:incoming_metadata) { { 'title_value' => ['the 400 Blows', 'Les quatres-cents coups'], 'title_language' => ['eng', 'fra'] } }
        let(:expected_literals) do
          [RDF::Literal('the 400 Blows', language: :eng), RDF::Literal('Les quatres-cents coups', language: :fra)]
        end

        it 'converts field _values and _languages into language-tagged RDF literals' do
          expect { form.validate(incoming_metadata) }
            .to change { form.send(field) }
            .from([])
            .to(expected_literals)
        end
      end
    end
  end
end