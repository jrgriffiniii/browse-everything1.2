# frozen_string_literal: true

module BrowseEverything
  module Driver
    class FileSystem < Base
      def self.upload_resource_class
        BrowseEverything::Upload::FileSystem::Resource
      end

      def icon
        'file'
      end

      # @todo Is this needed?
      def remote_root_path
        config[:home]
      end

      def validate_config
        if remote_root_path.blank?
          raise(
            BrowseEverything::Driver::ConfigurationError,
            'FileSystem driver requires a :home argument'
          )
        end
      end

      def pages
        @pages ||= begin
                     first_page = Page.new(index: 0)
                     [first_page]
                   end
      end

      def current_page
        pages.last
      end

      def paginate(remote_resource)
        current_page << remote_resource
      end

      # Retrieve the contents of a directory
      # @param path [String] the path to a file system resource
      # @return [Array<BrowseEverything::RemoteFile>]
      def contents(path: '')
        remote_resource_path = File.join(remote_root_path, path)
        remote_resource = self.class.upload_resource_class.build(path: remote_resource_path)

        paginate(remote_resource)
        pages
      end

      def link_for(path)
        full_path = File.expand_path(path)
        file_size = file_size(full_path)
        ["file://#{full_path}", { file_name: File.basename(path), file_size: file_size }]
      end

      def authorized?
        true
      end

      # Construct a RemoteFile objects for a file-system resource
      # @param path [String] path to the file
      # @param display [String] display label for the resource
      # @return [BrowseEverything::RemoteFile]
      def details(path, display = File.basename(path))
        return nil unless File.exist? path
        info = File::Stat.new(path)
        BrowseEverything::RemoteFile.new(
          make_pathname(path),
          [key, path].join(':'),
          display,
          info.size,
          info.mtime,
          info.directory?
        )
      end

      private

      # Construct an array of RemoteFile objects for the contents of a
      # directory
      # @param real_path [String] path to the file system directory
      # @return [Array<BrowseEverything::RemoteFile>]
      def make_directory_entry(real_path)
        entries = []
        entries + Dir[File.join(real_path, '*')].collect { |f| details(f) }
      end

      def make_pathname(path)
        Pathname.new(File.expand_path(path)).relative_path_from(Pathname.new(config[:home]))
      end

      def file_size(path)
        File.size(path).to_i
      rescue StandardError => error
        Rails.logger.error "Failed to find the file size for #{path}: #{error}"
        0
      end
    end
  end
end
