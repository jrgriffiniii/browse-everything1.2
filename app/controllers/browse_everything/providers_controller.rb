# frozen_string_literal: true
require_dependency "browse_everything/application_controller"

module BrowseEverything
  class ProvidersController < ApplicationController
    def upload
      @upload = BrowseEverything::Upload.new(**upload_attributes)
      # @todo This is where the job is enqueued
      # @upload.perform_job_later

      respond_to do |format|
        format.html do
          flash[:notice] = "Upload is enqueued for processing..."
          redirect_to action: :index
        end
        format.json do
          render json: @upload
        end
      end
    rescue StandardError => error
      respond_to do |format|
        format.html do
          Rails.logger.error("Failed to upload the files: #{error}")
          render status: 500
        end
        format.json do
          render json: "Server Error: #{error}", status: 500
        end
      end
    end

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

    def upload_params
      # params.require(:upload).permit(:id, :authenticity_token)
      required = params.require(:upload)
      required.permit!
    end

    def upload_attributes
      {
        uris: upload_params.keys
      }
    end

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
