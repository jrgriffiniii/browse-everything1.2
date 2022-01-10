# frozen_string_literal: true
module BrowseEverything
  class ApplicationController < ActionController::Base
    def show
      render partial: 'files', layout: !request.xhr?
    end

    def index
      @providers = Driver.all

      render layout: !request.xhr?
    end
  end
end
