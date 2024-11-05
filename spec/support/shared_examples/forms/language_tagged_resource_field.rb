# frozen_string_literal: true
RSpec.shared_examples 'a language-tagged resource field' do
  before do
    raise 'Specify a field using `let(:field)`' unless defined? field
  end

  # @todo I think this changes in Hyrax 5.0 to:
  # let(:form) { described_class.for(resource: resource) }
  let(:form) { described_class.new(resource) }
  let(:resource) { resource_class.new }
  let(:resource_class ) { described_class.name.split('::').last.gsub(/Form$/, '').constantize }
  let(:form_definitions) { described_class.definitions }
  let(:field_is_multiple) { form_definitions[field.to_s][:multiple] }

  let(:field_language_key) { "#{field}_language" }
  let(:field_value_key) { "#{field}_value" }

  let(:tagged_literal_language) { :eng }
  let(:tagged_literal_value) { "Literal value" }
  let(:tagged_literal) { RDF::Literal(tagged_literal_value, language: tagged_literal_language) }

  it 'adds a virtual _language property' do
    expect(form_definitions.keys).to include(field_language_key)
    expect(form_definitions[field_language_key][:writeable]).to be false
    expect(form_definitions[field_language_key][:readable]).to be false
  end

  it 'adds a virtual _value property' do
    expect(form_definitions.keys).to include(field_value_key)
    expect(form_definitions[field_value_key][:writeable]).to be false
    expect(form_definitions[field_value_key][:readable]).to be false
  end

  describe 'prepopulation' do
    before do
      resource.send("#{field}=", field_is_multiple ? [tagged_literal] : tagged_literal)
    end

    it 'populates _value' do
      expect { form.prepopulate! }
        .to change { form.send(field_value_key.to_sym) }
        .from([])
        .to(field_is_multiple ? [tagged_literal_value] : tagged_literal_value)
    end

    it 'populates _language' do
      expect { form.prepopulate! }
        .to change { form.send(field_language_key.to_sym) }
        .from([])
        .to(field_is_multiple ? [tagged_literal_language.to_s] : tagged_literal_language.to_s)
    end
  end

  describe 'RDF Literal builder validation' do
    before do
      resource.send("#{field}=", field_is_multiple ? [] : nil)
    end

    let(:incoming_metadata) { { "#{field}_value" => ["the 400 Blows", "Les quatres-cents coups"], "#{field}_language" => ["eng", "fra"] } }
    let(:expected_literals) do
      [RDF::Literal('the 400 Blows', language: :eng), RDF::Literal('Les quatres-cents coups', language: :fra)]
    end

    it 'converts field _values and _languages into language-tagged RDF literals' do
      expect { form.validate(incoming_metadata) }
        .to change { form.send(field) }
        .from([])
        .to(field_is_multiple ? expected_literals : expected_literals.first)
    end
  end
end
