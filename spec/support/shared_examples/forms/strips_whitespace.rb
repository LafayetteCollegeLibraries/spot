# frozen_string_literal: true
RSpec.shared_examples 'it strips whitespaces from values' do
  subject(:attributes) { described_class.model_attributes(params) }

  let(:field) { :resource_type }
  let(:params) { ActionController::Parameters.new(raw_params) }
  let(:raw_params) { { field => [' value   ', '  '] } }

  it do
    expect(attributes[field]).to eq ['value']
  end
end
