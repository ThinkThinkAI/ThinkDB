# frozen_string_literal: true
require 'sidekiq/web'

Rails.application.routes.draw do # rubocop:disable Metrics/BlockLength
  resources :messages
  resources :chats
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

    resources :chats do
      resources :messages, only: %i[create destroy]
    end
  end

  get '/chat', to: 'chats#index'

  get 'users/settings', to: 'users#settings', as: 'user_settings'
  patch 'users/settings', to: 'users#settings'

  root to: 'home#index'
  get '/swatch', to: 'home#swatch'

  mount Sidekiq::Web => '/sidekiq'
  mount ActionCable.server => '/cable'
end
