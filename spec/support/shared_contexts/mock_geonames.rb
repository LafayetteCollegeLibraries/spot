# frozen_string_literal: true
#
# Provides hooks to mock a successful response from the GeoNames API server.
# Redefine the variables within
#
# @see http://www.geonames.org/export/web-services.html
RSpec.shared_context 'mock GeoNames RDF response' do
  let(:mock_geonames_uri) { 'http://sws.geonames.org/5188140/' }
  let(:mock_geonames_id) { URI.parse(mock_geonames_uri).path.delete('/') }
  let(:mock_geonames_json_uri) { "http://www.geonames.org/getJSON?geonameId=#{mock_geonames_id}&username=#{mock_geonames_username}" }
  let(:mock_geonames_response) { { 'name' => 'Easton', 'adminName1' => 'Pennsylvania', 'countryName' => 'United States' } }
  let(:mock_geonames_username) { Qa::Authorities::Geonames.username }

  before do
    stub_request(:get, mock_geonames_json_uri).to_return(body: JSON.dump(mock_geonames_response))
  end
end
