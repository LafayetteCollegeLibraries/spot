# frozen_string_literal: true
require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users

  # need to call `root` before mounting our engines
  root 'spot/homepage#index'

  mount Blacklight::Engine => '/'
  mount BlacklightAdvancedSearch::Engine => '/'
  mount Hydra::RoleManagement::Engine => '/admin'
  mount Hyrax::Engine, at: '/'
  mount Riiif::Engine => 'images', as: :riiif if Hyrax.config.iiif_image_server?
  mount Sidekiq::Web => '/sidekiq'
  mount Qa::Engine => '/authorities'

  concern :exportable, Blacklight::Routes::Exportable.new
  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable
  end

  curation_concerns_basic_routes

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  scope module: 'spot' do
    # adding administrative pages to the site. we'll keep them under
    # the 'spot' module, but not include that in the url (hence the
    # +scope module: 'spot'+ call). note that +hydra-role-management+
    # isn't here because we're mounting it on '/admin'.
    namespace :admin do
      resource :status, only: :show, controller: 'status'
    end

    resources :collections, only: [] do
      member do
        resource :featured_collection, only: [:create, :destroy]
      end
    end
  end

  get '/handle/*id', to: 'identifier#handle', as: 'handle'
end
