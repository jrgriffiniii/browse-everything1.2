# frozen_string_literal: true

module BrowseEverything
  module Upload
    class Directory < Resource
      def self.directory_mime_type
        'application/x-directory'
      end

      def initialize(type: nil, **opts)
        @type = type || self.class.directory_mime_type

        super(**opts)
      end
    end
  end
end
