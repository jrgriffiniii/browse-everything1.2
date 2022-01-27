# frozen_string_literal: true
require_dependency "browse_everything/application_controller"

module BrowseEverything
  class ProvidersController < ApplicationController
    def browse
      @provider = current_provider
      @pages = @provider.browse(path: browse_path)

      respond_to do |format|
        format.html do
          render status: 404 if @pages.nil?
          render :browse, layout: !request.xhr?
        end
        format.json do
          render json: "404 Not Found", status: 404 if @pages.nil?
          render json: @pages
        end
      end
    end

    def show
      @provider = current_provider

      respond_to do |format|
        format.html do
          render status: 404 if @provider.nil?
          render :show, layout: !request.xhr?
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

    def provider_id
      params[:id]
    end

    def browse_path
      params[:path]
    end

    def current_provider
      Driver.build(id: provider_id.to_sym)
    end
  end
end
