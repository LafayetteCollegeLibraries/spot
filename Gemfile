# frozen_string_literal: true
source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

#
# the base rails stack (installed with 'rails new spot')
#
gem 'rails', '~> 5.2'

# use Puma as the app server (dev only, we're using passenger in production)
gem 'puma', '3.12.6'

# Use SCSS for stylesheets
gem 'sass-rails', '5.0.7'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '4.1.20'

# ugh, we're stuck with coffee-script until it's out of hyrax i guess
gem 'coffee-rails', '4.2.2'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '5.2.1'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '2.10.0'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', '~> 1.2018', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

#
# the hyrax/spot stack
#
gem 'hyrax', '~> 2.9.0'

# modularize our javascripts
gem 'almond-rails', '0.3.0'

# parse + build bagit-compliant files
gem 'bagit', '0.4.3'

# blacklight plugins for enhanced searching
gem 'blacklight_advanced_search', '6.4.1'
gem 'blacklight_oai_provider', '6.0.0'
gem 'blacklight_range_limit', '6.3.3'

# start up the server faster
gem 'bootsnap', '1.4.7'

# record importer pattern from curationexperts
gem 'darlingtonia', '3.2.2'

# user management
gem 'devise', '4.7.1'
gem 'devise-guests', '0.7.0'
gem 'devise_cas_authenticatable', '1.10.4'

# we're using .env files to manage our secrets
gem 'dotenv-rails', '2.7.5'

# extended date formats
gem 'edtf', '3.0.4'
gem 'edtf-humanize', '0.0.7'

# error trackijng
gem 'honeybadger', '4.7.0'

# allows us to create admin (and more!) roles for users
gem 'hydra-role-management', '1.0.2'

# an authorative source for our two-character language codes
gem 'iso-639', '0.3.5'

# install jquery with rails (no longer the default)
gem 'jquery-rails', '4.3.5'

# system monitoring
gem 'okcomputer', '1.18.1'

# we're using postgres as our database within rails
gem 'pg', '1.2.3'

# this is bundled somewhere within the hyrax stack, but since we're
# calling it within our code we shouldn't expect it to always be there
gem 'rdf-vocab', '3.1.4'

# solr client for interacting with rails (installed w/ hyrax)
gem 'rsolr', '2.3.0'

# used in conjunction with our importers to zip/unzip files
gem 'rubyzip', '1.3.0'

# our jobs server
gem 'sidekiq', '5.2.9'
gem 'sidekiq-cron', '1.1.0'

# using Slack for some of our messaging
gem 'slack-ruby-client', '0.14.4'

# now that we're writing es6 javascript of our own (+ not just using the hyrax js)
# we need to compile it in sprockets.
#
# note from hyrax source:
#   When we upgrade to Sprockets 4, we can ditch sprockets-es6 and config AMD
#   in this way:
#   https://github.com/rails/sprockets/issues/73#issuecomment-139113466
gem 'sprockets-es6'

# Blacklight/Hyrax use Kaminari for pagination, but since we're
# using it in other instances, we should require it just in case.
gem 'kaminari', '1.2.1'

# a bunch of samvera gems rely on Faraday already, but we'll
# require it as we're explicitly using it.
gem 'faraday', '0.17.3'

# mini_magick is a dependency of hydra-derivatives, but since we're
# calling it explicitly, we should require it.
gem 'mini_magick', '4.10.1'

# manually add this gem to enable questioning_authority to parse linked-data results
gem 'linkeddata', '~> 3.0'

# development dependencies (not as necessary to
# lock down versions here)
group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.3'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 2.1.0'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Use Capistrano for deployment
  gem 'capistrano', '~> 3.10', require: false
  gem 'capistrano-bundler', '~> 1.3'
  gem 'capistrano-ext', '~> 1.2.1'
  gem 'capistrano-passenger', '~> 0.2.0'
  gem 'capistrano-rails', '~> 1.3', require: false
  gem 'capistrano-sidekiq', '~> 1.0.3'

  gem 'xray-rails', '~> 0.3.1'
end

# things used for development + testing (again, not as
# necessary to lock down versions)
group :development, :test do
  gem 'bixby', '~> 2.0.0.pre.beta1'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara', '~> 3'
  gem 'capybara-screenshot', '~> 1.0.24'
  gem 'database_cleaner', '~> 1.8.5'
  gem 'equivalent-xml', '~> 0.6.0', require: false
  gem 'factory_bot_rails', '~> 5', require: false
  gem 'fcrepo_wrapper', '~> 0.9.0'
  gem 'hyrax-spec', '~> 0.3.2'
  gem 'rails-controller-testing', '~> 1.0.4'
  gem 'rspec', '~> 3.8'
  gem 'rspec-its', '~> 1.1'
  gem 'rspec-rails', '~> 3.6'
  gem 'rspec_junit_formatter', '~> 0.4.1'
  gem 'rubocop', '~> 0.63'
  gem 'rubocop-rspec', '~> 1.3'
  gem 'shoulda-matchers', '~> 4'
  gem 'simplecov', '~> 0.17', require: false
  gem 'solr_wrapper', '~> 2.1'
  gem 'stub_env', '~> 1.0.4'
  gem 'webdrivers', '~> 4'
  gem 'webmock', '~> 3.8'
end
