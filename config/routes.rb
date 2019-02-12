# frozen_string_literal: true
require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users

  # need to call `root` before mounting our engines
  root 'spot/pages#homepage'

  mount Blacklight::Engine => '/'
  mount BlacklightAdvancedSearch::Engine => '/'
  mount Hydra::RoleManagement::Engine => '/admin'
  mount Hyrax::Engine, at: '/'
  mount Riiif::Engine => 'images', as: :riiif if Hyrax.config.iiif_image_server?
  mount Sidekiq::Web => '/sidekiq'
  mount Qa::Engine => '/authorities'
  mount OkComputer::Engine, at: '/status'

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

  # integrating hydra-role-management within our dashboard.
  # using +scope module: 'hyrax'+ will say that we're expecting
  # to use +Hyrax::Admin::RolesController+ without having
  # +/hyrax+ in our path.
  # scope module: 'hyrax' do
  #   namespace :admin do
  #     resources :roles, as: 'role' do
  #       resources :users, only: [:create, :destroy], controller: 'hyrax/admin/user_roles'
  #     end
  #   end
  # end

  get '/handle/*id', to: 'identifier#handle', as: 'handle'
end
