# frozen_string_literal: true
RSpec.describe 'error page rendering', type: :request do
  describe '404' do
    it 'renders the 404 page' do
      without_detailed_exceptions do
        get '/this/does/not/exist'
      end

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include 'The page you requested could not be found.'
    end
  end

  describe '500 (catch-all)' do
    before do
      allow_any_instance_of(Spot::HomepageController).to receive(:index).and_raise('oops nope')
    end

    it 'falls-back to the 500 error page' do
      without_detailed_exceptions do
        get '/'
      end

      expect(response).to have_http_status(:internal_server_error)
      expect(response.body).to include 'Something went wrong!'
    end
  end
end
