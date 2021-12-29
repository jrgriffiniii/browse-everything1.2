# frozen_string_literal: true

module BrowseEverything
  module Upload
    module FileSystem
      autoload :Resource, 'browse_everything/upload/file_system/resource'
      autoload :File, 'browse_everything/upload/file_system/file'
      autoload :Directory, 'browse_everything/upload/file_system/directory'
    end
  end
end
