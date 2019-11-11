# frozen_string_literal: true
RSpec.describe 'error page rendering', type: :request do
  before { allow(Honeybadger).to receive(:notify) }

  describe '404' do
    it 'renders the 404 page' do
      without_detailed_exceptions do
        get '/this/does/not/exist'
      end

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include 'The page you requested could not be found.'
    end

    context '.txt' do
      it 'renders the error in plain text' do
        without_detailed_exceptions do
          get '/this/does/not/exist.txt'
        end

        expect(response).to have_http_status(:not_found)
        expect(response.body).to eq '404 Not Found'
      end
    end

    context '.json' do
      let(:json_response) do
        %({"error": true, "status": 404, "message": "Not Found"})
      end

      it 'renders the error as json' do
        without_detailed_exceptions do
          get '/this/does/not/exist.json'
        end

        expect(response).to have_http_status(:not_found)
        expect(response.body).to eq json_response
      end
    end
  end

  describe '500 (catch-all)' do
    before do
      allow(Spot::HomepageController).to receive(:new).and_return(mock_homepage)
      allow(mock_homepage).to receive(:index).and_raise('oops nope')
    end

    let(:mock_homepage) { instance_double(Spot::HomepageController) }

    it 'falls-back to the 500 error page' do
      without_detailed_exceptions do
        get '/'
      end

      expect(response).to have_http_status(:internal_server_error)
      expect(response.body).to include 'Something went wrong!'
    end
  end
end
