# frozen_string_literal: true
Rails.application.routes.draw do
  mount BrowseEverything::Engine => "/browse_everything"
end
