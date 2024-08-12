# frozen_string_literal: true

Rails.application.routes.draw do
  resources :queries, except: [:index] do
    collection do
      get :metadata
      get :data
    end
  end
  get '/query', to: 'queries#index'

  devise_for :users, controllers: {
    sessions: 'custom_sessions',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  resources :data_sources do
    member do
      get :connect
    end
    resources :tables, only: [:show]
    resources :queries
  end


   #get '/query', to: 'queries#index', as: 'query'

  get 'users/settings', to: 'users#settings', as: 'user_settings'
  patch 'users/settings', to: 'users#settings'

  root to: 'home#index'
  get '/swatch', to: 'home#swatch'
end
