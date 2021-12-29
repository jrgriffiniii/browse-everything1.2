# frozen_string_literal: true

module BrowseEverything
  module Upload
    module FileSystem
      class Directory < BrowseEverything::Upload::Directory
        def children
          glob_pattern = File.join(path, '*')
          child_resources = Dir[glob_pattern]
          @children ||= begin
                          child_resources.map { |c| Resource.build(path: c) }
                        end
        end
      end
    end
  end
end
