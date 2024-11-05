# frozen_string_literal: true
RSpec.shared_examples 'a nested attribute field' do
  before do
    raise 'Specify a field using `let(:field)`' unless defined? field
  end

  let(:resource) { resource_class.new(field => value) }
  let(:resource_factory ) { described_class.name.split('::').last.gsub(/Form$/, '').underscore.to_sym }
  let(:resource_class ) { described_class.name.split('::').last.gsub(/Form$/, '').constantize }
  let(:value) { field_is_multiple ? [_value] : _value }

  let(:form) { described_class.for(resource) }
  let(:form_definitions) { described_class.definitions }
  let(:field_is_multiple) { form_definitions[field.to_s][:multiple] }
  let(:field_attributes_key) { "#{field}_attributes" }
  let(:_value) { 'Nested attribute field value' }

  it 'adds a virtual _attributes property' do
    expect(form_definitions.keys).to include(field_attributes_key)
    expect(form_definitions[field_attributes_key][:writeable]).to be false
    expect(form_definitions[field_attributes_key][:readable]).to be false
  end

  describe 'prepopulation' do
    let(:expected_attributes) do
      { '0' => { 'id' => _value } }
    end

    it 'sets the resource value to the form value' do
      expect { form.prepopulate! }
        .to change { form.send(field_attributes_key) }
        .from(nil)
        .to(expected_attributes)
    end
  end

  describe 'population' do
    context 'when adding a value' do
      before do
        form.prepopulate!
      end

      let(:_value) { 'https://ldr.lafayette.edu' }
      let(:incoming_metadata) { { field_attributes_key => { '0' => { 'id' => 'https://ldr.lafayette.edu' }, '1' => { 'id' => 'https://lafayette.edu' } } } }

      it 'adds the value to the field' do
        expect { form.validate(incoming_metadata) }
          .to change { form.send(field).map(&:to_s) } # guard against URI fields
          .from(value)
          .to(['https://ldr.lafayette.edu', 'https://lafayette.edu'])
      end
    end

    context 'when removing a value' do
      before do
        form.validate(incoming_metadata)
      end

      let(:incoming_metadata) { { field_attributes_key => { '0' => {'id' => _value, '_destroy' => 'true'} } } }

      it 'removes the value from the field' do
        expect(form.send(field)).to be_empty
      end
    end
  end
end