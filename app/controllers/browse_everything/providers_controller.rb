# frozen_string_literal: true
require_dependency "browse_everything/application_controller"

module BrowseEverything
  class ProvidersController < ApplicationController
    def show
      @provider = Driver.build(id: provider_param)

      respond_to do |format|
        format.html do
          render status: 404 if @provider.nil?
          render partial: 'files', layout: !request.xhr?
        end
        format.json do
          render json: "404 Not Found", status: 404 if @provider.nil?
          render json: @provider
        end
      end
    end

    def index
      @providers = Driver.all

      respond_to do |format|
        format.html { render :index, layout: !request.xhr? }
        format.json { render json: @providers }
      end
    end

    private

    def provider_param
      params[:provider]
    end
  end
end
