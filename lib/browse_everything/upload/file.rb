# frozen_string_literal: true

module BrowseEverything
  module Upload
    class File < Resource
      def self.default_mime_type
        'application/octet-stream'
      end

      def self.find_mime_type(file_name:)
        ext_name = ::File.extname(file_name)
        Rack::Mime.mime_type(ext_name)
      end

      def initialize(type: nil, **opts)
        path = opts[:path]

        extracted_type = self.class.find_mime_type(file_name: path)
        @type = type || (extracted_type || self.class.default_mime_type)

        super(**opts)
      end
    end
  end
end
