# frozen_string_literal: true
RSpec.shared_examples 'it maps Islandora URLs to identifiers' do
  subject { mapper.identifier }

  let(:metadata) { { 'islandora_url' => ['http://digital.lafayette.edu/collections/example/aa1234'] } }

  it { is_expected.to include 'url:http://digital.lafayette.edu/collections/example/aa1234' }
end
