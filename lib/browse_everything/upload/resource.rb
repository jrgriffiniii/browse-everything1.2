# frozen_string_literal: true

module BrowseEverything
  module Upload
    class Resource
      attr_reader :path, :location, :name, :size, :mtime, :type

      # @todo location should be key
      def initialize(path:, location:, name:, type: nil)
        @path = path
        @location = location
        @name = name

        stat = ::File::Stat.new(path)
        @size = stat.size
        @mtime = stat.mtime

        @type = type
      end

      def relative_parent_path?
        name.match?(/^\.\.?$/)
      end
    end
  end
end
