# frozen_string_literal: true

module BrowseEverything
  module Upload
    autoload(:FileSystem, 'browse_everything/upload/file_system')

    autoload(:Resource, 'browse_everything/upload/resource')
    autoload(:Directory, 'browse_everything/upload/directory')
    autoload(:File, 'browse_everything/upload/file')
  end
end
