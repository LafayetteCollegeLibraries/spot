# frozen_string_literal: true
RSpec.shared_examples 'it strips whitespaces from values' do
  subject(:attributes) { described_class.model_attributes(params) }

  let(:params) { ActionController::Parameters.new(raw_params) }
  let(:raw_params) { { creator: ['   An important scholar   ', '  '] } }

  it do
    expect(attributes[:creator]).to eq ['An important scholar']
  end
end
