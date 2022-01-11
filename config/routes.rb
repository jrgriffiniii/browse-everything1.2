# frozen_string_literal: true
BrowseEverything::Engine.routes.draw do
  root to: 'providers#index'

  # match ':provider(/*path)', to: 'browse_everything#show', as: 'contents', via: %i[get post], format: false
  get 'providers/:id/browse/*path', to: 'providers#browse'
  get 'providers/:id', to: 'providers#show'
  get 'providers', to: 'providers#index'
end
