# frozen_string_literal: true
RSpec.shared_context 'mock WDS service' do
  before do
    stub_env('LAFAYETTE_WDS_API_KEY', 'abc123def!')

    allow(Spot::LafayetteWdsService)
      .to receive(:new)
      .with(api_key: anything)
      .and_return(mock_wds_instance)

    allow(mock_wds_instance).to receive(:instructors).with(term: anything).and_return(instructors_response)

    allow(mock_wds_instance).to receive(:person).with(email: anything).and_return(person_response)
    allow(mock_wds_instance).to receive(:person).with(username: anything).and_return(person_response)
    allow(mock_wds_instance).to receive(:person).with(lnumber: anything).and_return(person_response)
  end

  let(:mock_wds_instance) { instance_double('Spot::LafayetteWdsService') }

  # mocks for #instructor response
  let(:instructor_first_name) { 'Anne' }
  let(:instructor_last_name) { 'Instructor' }
  let(:instructor_email) { 'instruca@lafayette.edu' }
  let(:instructors_response) do
    [{
      'FIRST_NAME' => instructor_first_name,
      'LAST_NAME' => instructor_last_name,
      'EMAIL' => instructor_email.upcase
    }]
  end

  # mocks for person response
  let(:person_first_name) { instructor_first_name }
  let(:person_last_name) { instructor_last_name }
  let(:person_email) { instructor_email.downcase }
  let(:person_response) do
    {
      'FIRST_NAME' => person_first_name,
      'LAST_NAME' => person_last_name,
      'EMAIL' => person_email
    }
  end
end
