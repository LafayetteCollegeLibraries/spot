# frozen_string_literal: true
#
# Some of our feature specs (looking at you spec/features/oai_provider_spec.rb) require Capybara to have
# an app_host property set to 'http://127.0.0.1', whereas the majority of them benefit with this property
# blank, so in cases where it's needed, this context exists.
#
# @example
#   RSpec.feature 'Some wonky feature spec' do
#     include_context 'Capybara host'
#     # ...
#   end
RSpec.shared_context 'Capybara host' do |opts|
  opts ||= {}

  before do
    @old_capybara_host = Capybara.app_host
    Capybara.app_host = opts.fetch(:host, 'http://127.0.0.1')
  end

  after do
    Capybara.app_host = @old_capybara_host
  end
end
