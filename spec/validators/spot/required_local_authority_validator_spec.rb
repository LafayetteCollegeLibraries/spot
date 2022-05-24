# frozen_string_literal: true
RSpec.describe Spot::RequiredLocalAuthorityValidator do
  let(:validator) { described_class.new(options) }
  let(:options) { { field: field, authority: authority } }
  let(:field) { :resource_type }
  let(:authority) { 'resource_types' }
  let(:record) { Publication.new(resource_type: [resource_type_value]) }
  let(:resource_type_value) { 'Article' }

  describe '#validate' do
    context 'when the value is valid' do
      it 'attaches no errors' do
        validator.validate(record)

        expect(record.errors).to be_empty
      end
    end

    context 'when the value is invalid' do
      let(:resource_type_value) { 'Nothing' }

      it 'adds an error' do
        validator.validate(record)

        expect(record.errors).not_to be_empty
        expect(record.errors[field]).to include '"Nothing" is not a valid Resource Type.'
      end
    end

    context 'when the authority is not valid' do
      let(:authority) { 'nonexistent' }

      it 'raises an exception' do
        expect { validator.validate(record) }
          .to raise_error(RuntimeError)
      end
    end
  end
end
