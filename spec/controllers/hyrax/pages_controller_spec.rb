# frozen_string_literal: true
#
# just confirming that our override works
RSpec.describe Hyrax::PagesController do
  # need to load in the Hyrax routes
  # h/t: https://stackoverflow.com/a/22925768
  # see also: https://relishapp.com/rspec/rspec-rails/v/3-8/docs/routing-specs/engine-routes
  routes { Hyrax::Engine.routes }

  shared_examples 'it renders with hyrax layout' do
    subject { response }

    before { get :show, params: { key: key } }

    it { is_expected.not_to render_template('layouts/homepage') }
    it { is_expected.to render_template('layouts/hyrax') }
  end

  %w[about help terms agreement].each do |key_val|
    describe "GET #show => #{key_val}" do
      let(:key) { key_val }

      it_behaves_like 'it renders with hyrax layout'
    end
  end
end
