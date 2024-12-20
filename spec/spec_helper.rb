# frozen_string_literal: true
#
# envs for running `bundle exec rspec` against an infrastructure brought up using `docker compose up -d`
ENV['RAILS_ENV'] = 'test'
ENV['URL_HOST'] = 'http://localhost' if ENV['URL_HOST'].nil?

if ENV['COVERAGE'] || ENV['CI']
  ENV['DISABLE_BOOTSNAP'] = 'true'

  require 'simplecov'
  require 'simplecov-cobertura'
  SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
  SimpleCov.start 'rails' do
    add_filter 'lib/mailer_previews'
  end
end

require File.expand_path('../../config/environment', __FILE__)

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'
require 'factory_bot_rails'
require 'active_fedora/cleaner'
require 'capybara/rspec'
require 'capybara/rails'
require 'capybara-screenshot/rspec'
require 'hyrax/spec/matchers'
require 'hyrax/spec/shared_examples'
require 'hyrax/spec/factory_bot/build_strategies'
require 'hyrax/specs/shared_specs'
require 'webmock/rspec'
require 'rspec/matchers'
require 'equivalent-xml'
require 'equivalent-xml/rspec_matchers'
require 'mail'

Capybara.register_driver :selenium_firefox_headless do |app|
  browser_options = ::Selenium::WebDriver::Firefox::Options.new
  browser_options.binary = ENV['FIREFOX_BINARY_PATH'] if ENV['FIREFOX_BINARY_PATH'].present?
  browser_options.args << '--headless'
  Capybara::Selenium::Driver.new(app, browser: :firefox, options: browser_options)
end

Capybara.default_driver = :rack_test # This is a faster driver
Capybara.javascript_driver = :selenium_firefox_headless # This is slower

# Uncomment this block to watch feature tests run in a web browser
# Capybara.javascript_driver = :selenium
# Capybara.configure do |config|
#   config.default_max_wait_time = 10 # seconds
#   config.default_driver        = :selenium
# end

# since we've created a custsom driver (that is a wrapper around a Selenium
# driver), we need to tell capybara-screenshot how to take a screenshot
# (which is copied from the Selenium configuration)
Capybara::Screenshot.register_driver(:selenium_firefox_headless) do |driver, path|
  driver.browser.save_screenshot(path)
end

Capybara::Screenshot.prune_strategy = :keep_last_run

# require support files
Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.order = :random
  Kernel.srand config.seed

  ##
  # rspec/rails config
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # /end rspec/rails
  ##

  config.include Warden::Test::Helpers
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include FactoryBot::Syntax::Methods
  config.include StubEnv::Helpers
  config.include ControllerHelpers, type: :helper
  config.include Select2Helpers, type: :feature
  config.include Mail::Matchers, type: :mailer

  config.use_transactional_fixtures = false
  config.render_views = true

  # Borrowed from
  # https://github.com/samvera/hyrax/blob/4abc41f675ba990364ba9f02d4d06dbde986a75c/spec/spec_helper.rb#L193-L196
  #
  # Adds our controller helpers to the base helper
  config.before type: :helper do
    initialize_controller_helpers(helper)
  end

  config.before :suite do
    DatabaseCleaner.clean_with(:truncation)

    Hyrax.config.enable_noids = false
  end

  config.before do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end

  config.before clean: true do
    DatabaseCleaner.clean
    ActiveFedora::Cleaner.clean!
  end

  config.after clean: true do
    DatabaseCleaner.clean
  end

  config.before js: true do
    DatabaseCleaner.strategy = :truncation
  end
end

WebMock.disable_net_connect!(
  allow_localhost: true,
  net_http_connect_on_start: true,

  # account for our aliased services via docker
  allow: %w[
    objects.githubusercontent.com
    github.com
    db
    fedora
    fitsservlet
    solr
  ]
)

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
