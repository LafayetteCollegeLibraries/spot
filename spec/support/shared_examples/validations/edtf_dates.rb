# frozen_string_literal: true
RSpec.shared_examples 'it validates EDTF date fields' do |opts|
  opts ||= {}
  fields = opts.fetch(:fields, [])

  let(:form) { described_class.for(resource_class.new) }
  let(:resource_class) { described_class.name.split('::').last.gsub(/Form$/, '').constantize }

  Array.wrap(fields).map(&:to_sym).each do |field|
    describe "vaidates EDTF field #{field}" do
      before { form.validate(metadata) }

      let(:metadata) { { field => [field_value] } }

      context 'with a valid EDTF date' do
        let(:field_value) { '1986-02-11/2025-02-22' }

        it 'validates the field' do
          expect(form.errors.keys).not_to include field
        end
      end

      context 'with an invalid EDTF date' do
        let(:field_value) { 'Last Wednesday' }

        it 'adds an error to the form' do
          expect(form.errors[field]).to eq [%("#{field_value}" is not a valid EDTF date value.)]
        end
      end
    end
  end
end
