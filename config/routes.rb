# frozen_string_literal: true
BrowseEverything::Engine.routes.draw do
  root to: 'providers#index'

  get 'providers/:id/browse(/:path)', to: 'providers#browse', as: :provider_browse
  post 'providers/:id/upload', to: 'providers#upload', as: :provider_upload
  get 'providers/:id', to: 'providers#show', as: :provider
  get 'providers', to: 'providers#index'
end
