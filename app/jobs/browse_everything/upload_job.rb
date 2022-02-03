# frozen_string_literal: true
module BrowseEverything
  class UploadJob < ApplicationJob
    queue_as :default

    def perform(upload:)
      # no-op
    end
  end
end
