# frozen_string_literal: true
RSpec.shared_examples 'it validates field presence' do |options|
  options ||= {}

  raise 'presence shared_examples requires a :field option passed' unless options.include?(:field)

  let(:attributes) { attributes_for(work_factory).merge(extra_attributes) }
  let(:work_factory) { described_class.name.downcase.to_sym }
  let(:field) { options[:field].to_sym }
  let(:value) { options.fetch(:value, ['a value']) }
  let(:extra_attributes) { {} }
  let(:work) { described_class.new(attributes) }

  context 'when a value is present' do
    it 'validates the work' do
      expect(work).to be_valid
    end
  end

  context 'when a value is not present' do
    let(:extra_attributes) { { field => [] } }

    it 'adds an error to the record' do
      expect(work).not_to be_valid
      expect(work.errors[field]).to include "Your work must include a #{field.to_s.titleize}."
    end
  end
end
