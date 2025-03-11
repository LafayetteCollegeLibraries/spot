# frozen_string_literal: true
RSpec.shared_examples 'a controlled vocabulary field' do |opts|
  opts ||= {}
  let(:cv_klass) { opts[:class] || String }

  before do
    raise 'Specify a field using `let(:field)`' unless defined? field
  end

  let(:resource) { resource_class.new(field => value) }
  let(:resource_factory) { described_class.name.split('::').last.gsub(/Form$/, '').underscore.to_sym }
  let(:resource_class) { described_class.name.split('::').last.gsub(/Form$/, '').constantize }
  let(:value) { field_is_multiple ? [_value] : _value }

  let(:form) { described_class.for(resource) }
  let(:form_definitions) { described_class.definitions }
  let(:field_is_multiple) { form_definitions[field.to_s][:multiple] }
  let(:field_attributes_key) { "#{field}_attributes" }
  let(:cv_klass_is_cv) { cv_klass.new.is_a?(ActiveTriples::Resource) }
  let(:_value) do
    cv_klass_is_cv ? 'https://sws.geonames.org/5188153/' : 'Controlled Vocabulary attribute value'
  end
  let(:controlled_vocabulary_class) { String }

  it 'adds a virtual _attributes property' do
    expect(form_definitions.keys).to include(field_attributes_key)
    expect(form_definitions[field_attributes_key][:writeable]).to be false
    expect(form_definitions[field_attributes_key][:readable]).to be false
  end

  describe 'population' do
    context 'when adding a value' do
      before do
        form.prepopulate!
      end

      let(:_incoming_value) do
        cv_klass_is_cv ? 'https://sws.geonames.org/4943644/' : 'Second CV attribute'
      end

      let!(:incoming_metadata) do
        {
          field_attributes_key.to_sym => {
            '0' => { 'id' => _value },
            '1' => { 'id' => _incoming_value }
          }
        }
      end

      let(:mapped_incoming_values) do
        incoming_metadata[field_attributes_key.to_sym].map { |_idx, value| cv_klass.new(value['id']) }
      end

      it 'adds the value to the field' do
        expect { form.validate(incoming_metadata) }
          .to change { form.send(field) }
          .from(value)
          .to(field_is_multiple ? mapped_incoming_values : mapped_incoming_values.first)
      end
    end

    context 'when removing a value' do
      before do
        form.validate(incoming_metadata)
      end

      let(:incoming_metadata) do
        {
          field_attributes_key => {
            '0' => { 'id' => _value, '_destroy' => 'true' }
          }
        }
      end

      it 'removes the value from the field' do
        expect(form.send(field)).to be_empty
      end
    end
  end
end
