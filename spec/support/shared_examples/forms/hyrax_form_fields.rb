# frozen_string_literal: true
RSpec.shared_examples 'it includes Hyrax::FormFields' do |opts|
  opts ||= {}
  schema = opts.fetch(:schema, nil)
  raise 'Shared Example needs a :schema parameter passed' if schema.nil?

  skip_list = opts.fetch(:except, [])

  let(:form) { described_class.for(resource) }
  let(:resource) { resource_class.new }
  let(:resource_class) { described_class.name.to_s.split('::').last.gsub(/Form$/, '').constantize }

  SpecSchemaLoader.new.raw_attributes_for(schema: schema).each do |key, raw_attrs|
    next if skip_list.include?(key) || !raw_attrs.key?('form')

    describe "##{key}" do
      let(:is_multiple) { described_class.definitions[key.to_s][:multiple] == true }
      let(:uri_value) { RDF::URI.new('http://cool.org') }
      let(:string_value) { 'http://cool.org' }
      let(:value) do
        case raw_attrs['type']
        when 'uri'
          RDF::URI.new('http://cool.org')
        when 'date_time'
          DateTime.now
        else
          string_value
        end
      end
      let(:original_value) { [] }
      let(:expected_value) { is_multiple ? [value] : value }
      let(:change_value) { is_multiple ? [value.to_s] : value.to_s }

      it do
        expect { form[key] = change_value }
          .to change { form[key] }
          .from(original_value)
          .to(expected_value)
      end
    end
  end
end
