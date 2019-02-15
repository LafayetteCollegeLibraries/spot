# frozen_string_literal: true
RSpec.describe Spot::PagesController do
  describe '#homepage' do
    it 'renders the homepage layout' do
      get :homepage
      expect(response).to render_template('layouts/1_column_no_navbar')
    end
  end
end
