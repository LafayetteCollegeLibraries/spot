# frozen_string_literal: true
RSpec.describe StudentWorkIndexer do
  include_context 'indexing'

  it_behaves_like 'a Spot indexer'
  it_behaves_like 'it indexes a sortable date'

  describe 'advisor_label' do
    subject { solr_doc['advisor_label_ssim'] }

    let(:attributes) { { advisor: [advisor_email] } }
    let(:advisor_email) { 'malantoa@lafayette.edu' }

    context 'when WDS key is not present' do
      it { is_expected.to eq [advisor_email] }
    end

    context 'when WDS key is present' do
      let(:wds_service) { instance_double('Spot::LafayetteWdsService') }
      let(:person_payload) do
        { 'FIRST_NAME' => 'Anna', 'LAST_NAME' => 'Malantonio', 'EMAIL' => 'MALANTOA@LAFAYETTE.EDU' }
      end

      before do
        stub_env('LAFAYETTE_WDS_API_KEY', 'secret key')
        allow(Spot::LafayetteWdsService).to receive(:new).and_return(wds_service)
        allow(wds_service).to receive(:person).with(email: advisor_email).and_return(person_payload)
      end

      it { is_expected.to eq ["#{person_payload['LAST_NAME']}, #{person_payload['FIRST_NAME']}"] }
    end
  end
end
