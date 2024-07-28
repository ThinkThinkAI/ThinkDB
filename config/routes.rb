# frozen_string_literal: true

Rails.application.routes.draw do
  resources :queries
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

  get 'query', to: 'queries#index'

  get 'users/settings', to: 'users#settings', as: 'user_settings'
  patch 'users/settings', to: 'users#settings'

  root to: 'home#index'
  get '/swatch', to: 'home#swatch'
end
