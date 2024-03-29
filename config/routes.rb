# frozen_string_literal: true
require 'sidekiq/web'
require 'sidekiq/cron/web'
require 'rack'

Rails.application.routes.draw do
  ##
  # spot routing
  ##

  # user routes
  devise_for :users

  # need to call `root` before mounting our engines
  root 'spot/homepage#index'

  # putting these routes before the engines so that
  # we can beat Hyrax to defining these instead
  get '/about', to: 'spot/page#about', as: 'about'
  get '/help', to: 'spot/page#help', as: 'help'
  get '/terms-of-use', to: 'spot/page#terms_of_use', as: 'terms_of_use'

  # Hyrax's terms of use page is found at /terms, so we'll just redirect to ours
  get '/terms', to: redirect('/terms-of-use')

  # collections landing page
  get '/collections', to: 'spot/collections#index', as: 'collections'

  # only allow urls to be passed to the redirect controller
  get '/redirect', to: 'spot/redirect#show', constraints: lambda { |request|
    qs = Rack::Utils.parse_nested_query(request.query_string)
    qs.dig('url')&.match?(URI.regexp)
  }

  # handle uri catching: ldr.lafayette.edu/handle/:id
  resources :handle, only: :show, constraints: { id: %r{[0-9]+/[a-zA-Z0-9]+} }

  ##
  # routes for engines + hyrax
  ##
  mount Blacklight::Engine => '/'
  mount BlacklightAdvancedSearch::Engine => '/'
  mount Hydra::RoleManagement::Engine => '/admin'
  mount Hyrax::Engine, at: '/'
  mount OkComputer::Engine, at: '/healthcheck'
  mount Sidekiq::Web => '/sidekiq'
  mount Qa::Engine => '/authorities'
  mount Bulkrax::Engine, at: '/'
  mount BrowseEverything::Engine => '/browse'

  concern :exportable, Blacklight::Routes::Exportable.new
  concern :oai_provider, BlacklightOaiProvider::Routes.new
  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :oai_provider

    concerns :searchable
    concerns :range_searchable
  end

  curation_concerns_basic_routes

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  # hiding blacklight's bookmark feature for now, but keeping the option available for down the road
  #
  # resources :bookmarks do
  #   concerns :exportable

  #   collection do
  #     delete 'clear'
  #   end
  # end

  scope module: 'spot' do
    # adding administrative pages to the site. we'll keep them under
    # the 'spot' module, but not include that in the url (hence the
    # +scope module: 'spot'+ call). note that +hydra-role-management+
    # isn't here because we're mounting it on '/admin'.
    namespace :admin do
      resource :status, only: :show, controller: 'status'
      resource :fixity_checks, only: :show
    end

    resources :collections, only: [] do
      member do
        resource :featured_collection, only: [:create, :destroy]
      end
    end

    resources :export, only: :show
  end
end
