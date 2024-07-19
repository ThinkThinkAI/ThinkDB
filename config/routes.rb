# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  resources :data_sources do
    member do
      get :connect
    end
    resources :tables, only: [:show]
  end

  get 'users/settings', to: 'users#settings', as: 'user_settings'
  patch 'users/settings', to: 'users#settings'

  root to: 'home#index'
end
