# frozen_string_literal: true

module BrowseEverything
  class Upload
    class Validator < ActiveModel::Validator
      def validate(model)
        model.errors.add(:requests, "There must be at least one request for Request Models") if model.requests.blank?

        model.requests.each do |request|
          model.errors.add(:requests, "There must be at least one request for Request Models") if request.path.nil?
        end
      end
    end

    class FilesProxy
      def attach(**_args)
        # noop
      end
    end

    include ActiveModel::Model
    include ActiveModel::Serialization
    include ActiveModel::Validations::Callbacks

    attr_accessor :requests
    validates_with Validator

    def attributes
      {
        requests: requests
      }
    end

    def self.job_class
      BrowseEverything::UploadJob
    end

    def job
      self.class.job_class
    end

    def perform_job_now
      job.perform_now(upload: self)
    end

    def perform_job_later(**options)
      job.perform_later(upload: self, **options)
    end

    def save
      # @todo Integrate active_storage
    end

    def files
      FilesProxy.new
    end
  end
end
