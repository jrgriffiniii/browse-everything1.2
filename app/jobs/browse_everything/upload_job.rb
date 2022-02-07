# frozen_string_literal: true
module BrowseEverything
  class AssetRequestService
    def initialize(uri:)
      @uri = uri
    end

    def connection
      @connection ||= Faraday.new(
        url: @uri
      )
    end

    def file?
      true
    end

    def request(path: nil, params: nil, headers: nil)
      read_buffer, write_buffer = IO.pipe

      bytes = if file?
                File.read(path)
              else
                response = connection.get(path, params, headers)
                response.body
              end
      write_buffer.write(bytes)
      write_buffer.close
      read_buffer
    end
  end

  class UploadJob < ApplicationJob
    queue_as :default

    def perform(upload:)
      upload.uris.each do |uri|
        request_service = BrowseEverything::AssetRequestService.new(uri: uri)
        bytestream = request_service.request(path: uri.path, params: uri.params, headers: uri.headers)
        # upload.files.attach(bytestream.read)
        bytestream.close
        yield upload

        upload.save
      end
    end
  end
end
