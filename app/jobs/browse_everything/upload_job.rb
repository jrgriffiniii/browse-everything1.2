# frozen_string_literal: true

module BrowseEverything
  class AssetRequestJob < ApplicationJob
    def perform(uri:, headers: {}, params: {})
      request = BrowseEverything::Request.new(uri: uri, headers: headers, params: params)
      read_buffer, write_buffer = IO.pipe

      bytes = request.resolve

      write_buffer.write(bytes)
      write_buffer.close
      read_buffer
    end
  end

  class UploadJob < ApplicationJob
    queue_as :default

    def perform(upload:)
      upload.requests.each do |request|
        bytestream = AssetRequestJob.perform_now(uri: request.uri.to_s, headers: request.headers, params: request.params)
        upload.files.attach(
          io: bytestream,
          filename: request.filename,
          content_type: request.content_type,
          identify: false
        )
        bytestream.close

        upload.save
      end
    end
  end
end
