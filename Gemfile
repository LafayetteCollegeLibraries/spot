# frozen_string_literal: true
source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

#
# the base rails stack (installed with 'rails new spot')
#
gem 'rails', '5.1.6.1'

# use Puma as the app server (dev only, we're using passenger in production)
gem 'puma', '3.12.0'

# Use SCSS for stylesheets
gem 'sass-rails', '5.0.7'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '4.1.20'

# ugh, we're stuck with coffee-script until it's out of hyrax i guess
gem 'coffee-rails', '4.2.2'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '5.2.0'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '2.8.0'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', '~> 1.2018', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

#
# the hyrax/spot stack
#
gem 'hyrax', '2.4.1'

# modularize our javascripts
gem 'almond-rails', '0.1.0'

# parse + build bagit-compliant files
gem 'bagit', '0.4.3'

# blacklight plugins for enhanced searching
gem 'blacklight_advanced_search', '6.4.1'
gem 'blacklight_range_limit', '6.3.3'

# start up the server faster
gem 'bootsnap', '1.4.0'

# record importer pattern from curationexperts
gem 'darlingtonia', '3.0.3'

# user management
gem 'devise', '4.6.1'
gem 'devise-guests', '0.6.1'

# we're using .env files to manage our secrets
gem 'dotenv-rails', '2.7.0'

# allows us to create admin (and more!) roles for users
gem 'hydra-role-management', '1.0'

# an authorative source for our two-character language codes
gem 'iso-639', '0.2.8'

# install jquery with rails (no longer the default)
gem 'jquery-rails', '4.3.3'

# system monitoring
gem 'okcomputer', '1.17.3'

# we're using postgres as our database within rails
gem 'pg', '1.1.4'

# this is bundled somewhere within the hyrax stack, but since we're
# calling it within our code we shouldn't expect it to always be there
gem 'rdf-vocab', '3.0.4'

# a iiif server for ruby from curationexperts
gem 'riiif', '2.0.0'

# solr client for interacting with rails (installed w/ hyrax)
gem 'rsolr', '2.2.1'

# used in conjunction with our importers to zip/unzip files
gem 'rubyzip', '1.2.2'

# our jobs server
gem 'sidekiq', '5.2.5'
gem 'sidekiq-cron', '1.1.0'

gem 'slack-ruby-client', '0.14.1'

# development dependencies (not as necessary to
# lock down versions here)
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

  gem 'xray-rails', '~> 0.3.1'
end

# things used for development + testing (again, not as
# necessary to lock down versions)
group :development, :test do
  gem 'bixby', '~> 1.0.0'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara', '~> 3.12.0'
  gem 'capybara-screenshot', '~> 1.0.22'
  gem 'chromedriver-helper', '~> 2.1.0'
  gem 'coveralls', '~> 0.8', require: false
  gem 'database_cleaner', '~> 1.7.0'
  gem 'equivalent-xml', '~> 0.6.0', require: false
  gem 'factory_bot_rails', '~> 4.0', require: false
  gem 'fcrepo_wrapper', '~> 0.9.0'
  gem 'ffaker', '~> 2.10.0'
  gem 'hyrax-spec', '~> 0.3.2'
  gem 'rails-controller-testing', '~> 1.0.4'
  gem 'rspec-its', '~> 1.1'
  gem 'rspec-rails', '~> 3.6'
  gem 'rspec_junit_formatter', '~> 0.4.1'
  gem 'rubocop', '~> 0.52.1'
  gem 'selenium-webdriver', '~> 3.141'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'simplecov', '~> 0.16.1', require: false
  gem 'solr_wrapper', '~> 2.0.0'
  gem 'webmock', '~> 3.4.2'
end
