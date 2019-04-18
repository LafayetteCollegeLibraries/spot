# frozen_string_literal: true
RSpec.describe Spot::PageController do
  # currently, our page controller only provides
  # methods to render the associated templates,
  # rails style.
  %w[about help].each do |page|
    describe "##{page}" do
      it "renders the #{page}.html.erb page" do
        get page.to_sym

        expect(response).to render_template(page)
      end
    end
  end
end
