# frozen_string_literal: true
source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.4'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', '~> 1.2018', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'hyrax', '2.4.1'

gem 'almond-rails', '~> 0.1.0'
gem 'bagit', '~> 0.4.2'
gem 'blacklight_advanced_search', '~> 6.4.1'
gem 'blacklight_range_limit', '~> 6.3.3'
gem 'bootsnap', '~> 1.3.2'
gem 'darlingtonia', '~> 1.0'
gem 'devise', '~> 4.5.0'
gem 'devise-guests', '~> 0.6'
gem 'dotenv-rails', '~> 2.5.0'
gem 'hydra-role-management', '~> 1.0'
gem 'iso-639', '~> 0.2.8'
gem 'jquery-rails', '~> 4.3.3'
gem 'mimemagic', '~> 0.3.2'
gem 'okcomputer', '~> 1.17.3'
gem 'pg', '~> 1.1.3'
gem 'rdf-vocab', '~> 3.0.4'
gem 'rsolr', '>= 1.0'
gem 'rubyzip', '~> 1.2.2'
gem 'sidekiq', '~> 5.2.3'

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 2.0.2'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Use Capistrano for deployment
  gem 'capistrano', '~> 3.10', require: false
  gem 'capistrano-bundler', '~> 1.3'
  gem 'capistrano-ext', '~> 1.2.1'
  gem 'capistrano-passenger', '~> 0.2.0'
  gem 'capistrano-rails', '~> 1.3', require: false
  gem 'capistrano-sidekiq', '~> 0.20.0'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]

  gem 'fcrepo_wrapper', '~> 0.9.0'
  gem 'solr_wrapper', '~> 2.0.0'

  gem 'database_cleaner', '~> 1.7.0'
  gem 'factory_bot_rails', '~> 4.0', require: false
  gem 'ffaker', '~> 2.10.0'
  gem 'rails-controller-testing', '~> 1.0.4'
  gem 'rspec-its', '~> 1.1'
  gem 'rspec-rails', '~> 3.6'
  gem 'shoulda-matchers', '~> 3.1'

  gem 'capybara', '~> 3.12.0'
  gem 'capybara-screenshot', '~> 1.0.22'
  gem 'chromedriver-helper', '~> 2.1.0'
  gem 'selenium-webdriver', '~> 3.141'

  gem 'pry-rails', '~> 0.3.8'
  gem 'webmock', '~> 3.4.2'

  gem 'bixby', '~> 1.0.0'
  gem 'rubocop', '~> 0.52.1'
end

group :test do
  gem 'coveralls', '~> 0.8', require: false
  gem 'hyrax-spec', '~> 0.3.2'
  gem 'simplecov', '~> 0.16.1', require: false
end

gem 'riiif', '~> 1.1'
