# frozen_string_literal: true

require 'faraday'

module BrowseEverything
  class Request < Faraday::Request; end
  class URI < URI::Generic; end

  class Upload
    class Validator < ActiveModel::Validator
      def validate(model)
        model.errors.add(:uris, "There must be at least one URI for Upload Models") if model.uris.blank?
      end
    end

    include ActiveModel::Model
    include ActiveModel::Serialization
    include ActiveModel::Validations::Callbacks

    attr_accessor :uris
    validates_with Validator
    before_validation :normalize_uris

    def attributes
      {
        uris: uris
      }
    end

    def self.job_class
      BrowseEverything::UploadJob
    end

    def job
      self.class.job_class
    end

    def perform_job
      job.perform(upload: self)
    end

    def perform_job_later(**options)
      job.perform_later(upload: self, **options)
    end

    def normalize_uris
      values = @uris.flatten.map do |value|
        if value.is_a?(URI::Generic)
          value
        else
          URI(value)
        end
      end

      self.uris = values
    end
    alias uris normalize_uris
  end
end
