# frozen_string_literal: true

module BrowseEverything
  module Upload
    module FileSystem
      class Resource < BrowseEverything::Upload::Resource
        def self.key
          :file_system
        end

        def self.build(path:)
          location = [key, path].join(':')
          name = ::File.basename(path)
          path_name = Pathname.new(path)

          opts = { path: path_name, location: location, name: name }

          if ::File.directory?(path)
            Directory.new(**opts)
          elsif ::File.file?(path)
            File.new(**opts)
          else
            raise(NotImplementedError, "File type for #{path} is not supported")
          end
        end
      end
    end
  end
end
