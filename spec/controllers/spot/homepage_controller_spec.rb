# frozen_string_literal: true
RSpec.describe Spot::HomepageController do
  describe '#index' do
    it 'renders the homepage layout' do
      get :index
      expect(response).to render_template('layouts/1_column_no_navbar')
    end
  end
end
