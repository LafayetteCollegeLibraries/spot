# frozen_string_literal: true
require 'sidekiq/web'

Rails.application.routes.draw do
  mount Blacklight::Engine => '/'
  mount Hydra::RoleManagement::Engine => '/'
  mount Hyrax::Engine, at: '/'
  mount Riiif::Engine => 'images', as: :riiif if Hyrax.config.iiif_image_server?
  mount Sidekiq::Web => '/sidekiq'
  mount Qa::Engine => '/authorities'

  concern :exportable, Blacklight::Routes::Exportable.new
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  devise_for :users

  resources :welcome, only: 'index'
  root 'hyrax/homepage#index'
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

  get '/handle/*id', to: 'identifier#handle', as: 'handle'
end
