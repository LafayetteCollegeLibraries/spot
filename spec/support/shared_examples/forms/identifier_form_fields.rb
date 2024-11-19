# frozen_string_literal: true
RSpec.shared_examples 'it supports local/standard identifiers' do
  let(:form) { described_class.for(resource) }
  let(:resource) { resource_class.new(**metadata) }
  let(:resource_class) { described_class.name.split('::').last.gsub(/Form$/, '').constantize }
  let(:identifier_field) { described_class.identifier_field }
  let(:metadata) { { identifier_field => ['noid:abc123def', 'issn:0000-0000', 'lafayette:magazine_1'] } }
  let(:form_definitions) { described_class.definitions }

  it 'adds virtual local_identifier and standard_identifier_* properties' do
    ['local_identifier', 'standard_identifier_prefix', 'standard_identifier_value'].each do |field|
      expect(form_definitions.keys).to include(field)
      expect(form_definitions[field][:writeable]).to be false
      expect(form_definitions[field][:readable]).to be false
    end
  end

  describe 'preopulation' do
    before do
      form.prepopulate!
    end

    it 'splits identifier values into standard_(prefix,value)' do
      expect(form.standard_identifier_prefix).to eq ['issn']
      expect(form.standard_identifier_value).to eq ['0000-0000']
    end

    it 'it puts local identifiers into their own field' do
      expect(form.local_identifier).to eq ['lafayette:magazine_1']
    end
  end

  describe 'validation for identifier field' do
    let(:metadata) { { identifier_field => ['noid:abc123def'] } }
    let(:incoming_metadata) do
      {
        'standard_identifier_prefix' => ['issn', 'oclc'],
        'standard_identifier_value' => ['0000-0000', '1264072606'],
        'local_identifier' => ['lafayette:magazine_1']
      }
    end

    it 'merges standard and local identifiers' do
      expect { form.validate(incoming_metadata) }
        .to change { form.send(identifier_field) }
        .from(['noid:abc123def'])
        .to(['noid:abc123def', 'issn:0000-0000', 'oclc:1264072606', 'lafayette:magazine_1'])
    end
  end
end
