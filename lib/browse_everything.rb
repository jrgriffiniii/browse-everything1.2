# frozen_string_literal: true
require "browse_everything/version"
require "browse_everything/engine"
require 'tempfile'

module BrowseEverything
  class Request < Net::HTTP::Get
    attr_reader :uri
    attr_reader :path
    attr_reader :headers
    attr_reader :params

    def self.build_uri(value)
      @uri = if value.is_a?(URI::Generic)
               value
             else
               URI(value)
             end
    end

    def initialize(uri:, params: {}, headers: {})
      @headers = headers
      unless @headers.empty?
        headers.each_pair do |k, v|
          self[k] = v
        end
      end

      parsed_uri = self.class.build_uri(uri)
      @path = if parsed_uri.path.empty?
                '/'
              else
                parsed_uri.path
              end

      # This is needed for the network requests
      super(@path, @headers)
      @uri = parsed_uri

      @params = params
      @uri.query = URI.encode_www_form(params) unless params.empty?
    end

    def send!
      @response ||= begin
                      Net::HTTP.start(uri.hostname, uri.port) do |http|
                        @response = http.request(self)
                      end

                      @response
                    end
    rescue StandardError => error
      Rails.logger.error("Request for the file failed: #{error}")
      raise(error.class, "Request for the file failed: #{error}")
    end

    def response
      @response || send!
    end

    def file?
      uri.scheme == 'file'
    end

    def file
      @file = Tempfile.new
      @file.write(response.body)
      @file.close
      @file
    end

    def file_path
      return uri.path if file?

      file.path
    end

    def filename
      File.basename(file_path)
    end

    def extension
      File.extname(filename)
    end

    def content_type
      Mime::Type.lookup_by_extension(extension)
    end

    def resolve
      if file?
        File.read(path)
      else
        return nil if response.code != '200'
        response.body
      end
    end
  end

  autoload(:Driver, 'browse_everything/driver')
  autoload(:Upload, 'browse_everything/upload')
end
