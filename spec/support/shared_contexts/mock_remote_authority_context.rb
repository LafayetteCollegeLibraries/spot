# frozen_string_literal: true
RSpec.shared_context 'mock remote authorities' do
  before do
    stub_request(:get, /geonames\.org/).to_return(body: '{}')
    stub_request(:get, /fast\.oclc\.org/).to_return(body: '{"response" => {"docs" => []}}')
  end
end