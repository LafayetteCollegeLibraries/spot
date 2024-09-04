# frozen_string_literal: true
RSpec.describe Spot::ControlledVocabularies::AssignFastSubject do
  subject(:resource) { described_class.new(uri) }

  let(:fast_id_number) { '485998' }
  let(:fast_id) { "fst#{fast_id_number}" }
  let(:resource_label) { "Wishman, Doris, 1920-2002" }

  describe '#fetch' do
    let(:search_url) do
      "http://fast.oclc.org/searchfast/fastsuggest?&query=#{fast_id_number}&queryIndex=idroot&queryReturn=idroot%2Cidroot%2Cauth%2Ctype&suggest=autoSubject&rows=20"
    end

    let(:search_response) do
      {
        'response' => {
          'numFound' => 2,
          'start' => 0,
          'docs' => search_response_docs
        }
      }
    end

    let(:search_response_docs) do
      [
        { 'idroot' => [fast_id], 'type' => 'auth', 'auth' => resource_label },
        { 'idroot' => [fast_id], 'type' => 'alt', 'auth' => "#{resource_label} ALT" }
      ]
    end

    before do
      stub_request(:get, search_url)
        .to_return(status: 200, body: JSON.dump(search_response))
    end

    context "when the subject's URI is a valid FAST URI" do
      it 'fetches a label from the FAST API' do
        expect { resource.fetch }
          .to change { resource.rdf_label }
          .from([uri])
          .to([resource_label])
      end

      it 'stores the label in the RdfLabel cache' do
        RdfLabel.destroy_all

        expect { resource.fetch }.to change { RdfLabel.count }.from(0).to(1)
      end
    end

    context 'when an "auth" response is not returned' do
      let(:search_response_docs) do
        [
          { 'idroot' => [fast_id], 'type' => 'alt', 'auth' => "Alt. Label 1" },
          { 'idroot' => [fast_id], 'type' => 'alt', 'auth' => "Alt. Label 2" }
        ]
      end

      before do
        resource.fetch
      end

      it 'uses the first label returned' do
        expect(resource.rdf_label).to eq(['Alt. Label 1'])
      end
    end

    context "when the subject's URI is not a FAST URI" do
      let(:uri) { 'http://id.loc.gov/authorities/names/no2002099753' }

      before do
        stub_request(:get, uri)
      end

      it 'attempts to fetch via a `super` call' do
        resource.fetch
        expect(WebMock).to have_requested(:get, uri)
      end
    end
  end
end
