# frozen_string_literal: true
source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

#
# the base rails stack (installed with 'rails new spot')
#
gem 'rails', '~> 5.2.7'

# use Puma as the app server
gem 'puma', '~> 6.4.0'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.1.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '~> 4.2.0'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5.2.1'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.11.5'

#
# the hyrax/spot stack
#
gem 'hyrax', '~> 3.6.0'

# modularize our javascripts
gem 'almond-rails', '~> 0.3.0'

# Citation parser to extract meta data for google scholar
gem 'anystyle', '~> 1.4.1'

# interact with assets in s3 buckets
gem 'aws-sdk-s3', '~> 1.142.0'

# parse + build bagit-compliant files
gem 'bagit', '~> 0.4.5'

# blacklight plugins for enhanced searching
gem 'blacklight_advanced_search', '~> 6.4.1'
gem 'blacklight_oai_provider', '~> 6.0.0'
gem 'blacklight_range_limit', '~> 6.3.3'

# start up the server faster
gem 'bootsnap', '~> 1.17', require: false

# Bulkrax for batch ingesting objects
gem 'browse-everything', '~> 1.1.2'
gem 'bulkrax', '~> 5.5.1'

# This needs to be here if we want to compile our own JS
# (there's like a single coffee-script file still remaining in hyrax)
gem 'coffee-rails', '~> 5.0.0'

# user management
gem 'devise', '~> 4.9.0'
gem 'devise_cas_authenticatable', '~> 2.0.2'
gem 'devise-guests', '~> 0.8.1'

# we're using .env files to manage our secrets
gem 'dotenv-rails', '~> 2.7.6'

# extended date formats
gem 'edtf', '~> 3.1.1'
gem 'edtf-humanize', '~> 2.1.0'

# a bunch of samvera gems rely on Faraday already, but we'll
# require it as we're explicitly using it.
gem 'faraday', '~> 0.17.6'

# error trackijng
gem 'honeybadger', '~> 4.12.1'

# allows us to create admin (and more!) roles for users
gem 'hydra-role-management', '~> 1.1.0'

# an authorative source for our two-character language codes
gem 'iso-639', '~> 0.3.6'

# install jquery with rails (no longer the default)
gem 'jquery-rails', '~> 4.6.0'

# Blacklight/Hyrax use Kaminari for pagination, but since we're
# using it in other instances, we should require it just in case.
gem 'kaminari', '~> 1.2.2'

# mini_magick is a dependency of hydra-derivatives, but since we're
# calling it explicitly, we should require it.
gem 'mini_magick', '~> 4.11'

# manually add this gem to enable questioning_authority to parse linked-data results
gem 'linkeddata', '~> 3.1.6'

# Generate non-digested copies of application.css and application.js
# (allows us to reference assets in the static error pages)
gem 'non-digest-assets', '~> 2.2.0'

# system monitoring
gem 'okcomputer', '~> 1.18.5'

# we're using postgres as our database within rails
gem 'pg', '~> 1.5.4'

# this is bundled somewhere within the hyrax stack, but since we're
# calling it within our code we shouldn't expect it to always be there
gem 'rdf-vocab', '~> 3.2.7'

# solr client for interacting with rails (installed w/ hyrax)
gem 'rsolr', '~> 2.5.0'

# used in conjunction with our importers to zip/unzip files
gem 'rubyzip', '~> 2.3.2'

# our jobs server
gem 'sidekiq', '~> 5.2.9'
gem 'sidekiq-cron', '~> 1.9.1'

# using Slack for some of our messaging
gem 'slack-ruby-client', '~> 0.14.6'

# now that we're writing es6 javascript of our own (+ not just using the hyrax js)
# we need to compile it in sprockets.
#
# note from hyrax source:
#   When we upgrade to Sprockets 4, we can ditch sprockets-es6 and config AMD in this way:
#   https://github.com/rails/sprockets/issues/73#issuecomment-139113466
gem 'sprockets-es6', '~> 0.9.2'

# Locking "redlock" to < 2.0, as the 2.x series currently breaks Sidekiq jobs.
# @see https://github.com/samvera/hyrax/pull/5961
# @todo remove when Hyrax 3.5.1 or 3.6 (whichever includes it) drops
gem 'redlock', '>= 0.1.2', '< 2.0'

# This is locked in hydra_editor > v6 to prevent an update
# that throws off how forms are built in Hyrax.
gem 'simple_form', '< 5.2'

# development dependencies (not as necessary to lock down versions here)
group :development do
  # Seed data
  # gem 'ldr-development-seeds', github: 'LafayetteCollegeLibraries/ldr-development-seeds', branch: 'main'

  gem 'listen', '>= 3.0.5', '< 3.8'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 2.1.1'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# things used for development + testing (again, not as necessary to lock down versions)
group :development, :test do
  gem 'bixby', '~> 5.0.1'
  gem 'byebug', '~> 11.1.3'
  gem 'capybara', '~> 3.38'
  gem 'capybara-screenshot', '~> 1.0.26'
  gem 'database_cleaner', '~> 2.0.1'
  gem 'equivalent-xml', '~> 0.6.0', require: false
  gem 'factory_bot_rails', '~> 6', require: false
  gem 'hyrax-spec', '~> 0.3.2'
  gem 'rails-controller-testing', '~> 1.0.5'
  gem 'rspec', '~> 3.10'
  gem 'rspec-its', '~> 1.1'
  gem 'rspec_junit_formatter', '~> 0.4.1'
  gem 'rspec-rails', '~> 5.1'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', '~> 4'
  gem 'simplecov', '~> 0.21.2', require: false
  gem 'simplecov-cobertura', '~> 2.1', require: false
  gem 'stub_env', '~> 1.0.4'
  gem 'webmock', '~> 3.8'
end
