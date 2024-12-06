# frozen_string_literal: true
RSpec.shared_examples 'it includes Hyrax::FormFields' do |opts|
  opts ||= {}
  schema = opts.fetch(:schema, nil)
  raise 'Shared Example needs a :schema parameter passed' if schema.nil?

  skip_list = opts.fetch(:except, [])
  schema_loader = SpecSchemaLoader.new
  form_definitions = schema_loader.form_definitions_for(schema: schema)

  let(:form) { described_class.for(resource) }
  let(:resource) { resource_class.new }
  let(:resource_class) { described_class.name.to_s.split('::').last.gsub(/Form$/, '').constantize }

  form_definitions.each_pair do |key, _attrs|
    next if skip_list.include?(key)

    field_def = schema_loader.raw_attributes_for(schema: schema).fetch(key)
    is_uri = field_def['type'] == 'uri'

    describe "##{key}" do
      let(:original_value) { [] }
      let(:expected_value) { is_uri ? [RDF::URI.new('http://cool.org')] : ['Test Value'] }
      let(:change_value) { is_uri ? ['http://cool.org'] : ['Test Value'] }

      it do
        expect { form[key] = change_value }
          .to change { form[key] }
          .from(original_value)
          .to(expected_value)
      end
    end
  end
end
