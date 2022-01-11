# frozen_string_literal: true

module BrowseEverything
  module Driver
    class FileSystem < Base
      def self.upload_resource_class
        BrowseEverything::Upload::FileSystem::Resource
      end

      class Configuration < OpenStruct
        def valid?
          to_h.key?(:home)
        end
      end

      # Is this needed?
      def self.configuration_class
        Configuration
      end

      class ResourceUpload
        attr_reader :uri, :local_path, :parent

        def initialize(**options)
          unresolved = options[:uri]
          @uri_path = unresolved.to_s.gsub('file://', '')
          raise(StandardError, "Attempted to resolve an empty file system path") if @uri_path.blank?

          expanded_resource_path = File.expand_path(@uri_path)
          @local_path = Pathname.new(expanded_resource_path)

          @parent = options[:parent]
          @uri = "file://#{path}"
        end

        def path
          @path ||= begin
                      leaf_path = if !parent.nil?
                                    parent_path = parent.path
                                    basename = File.basename(@uri_path)
                                    File.join(parent.path, basename)
                                  else
                                    parent_path = File.dirname(@uri_path)
                                    @uri_path.gsub(parent_path.to_s, '')
                                  end

                      Pathname.new(leaf_path)
                    end
        end
      end

      class DirectoryUpload < ResourceUpload
        def initialize(**options)
          super(**options)
          raise(StandardError, "#{local_path} is not a valid directory path") unless File.directory?(local_path)
        end

        def children
          @children ||= begin
                          child_entries = Dir.children(local_path)
                          child_entries.map do |child_entry|
                            #child_path = "#{local_path}/#{child_entry}"
                            child_path = File.join(local_path, child_entry)
                            child_uri = "file://#{child_path}"

                            if File.directory?(child_path)
                              self.class.new(uri: child_uri, parent: self)
                            else
                              FileUpload.new(uri: child_uri, parent: self)
                            end
                          end
                        end
        end
      end

      class FileUpload < ResourceUpload
        def initialize(**options)
          super(**options)
          raise(StandardError, "#{local_path} is not a valid file path") unless File.file?(local_path)
        end
      end

      class ResourceTree
        attr_reader :root

        def initialize(root_uri:)
          @root = DirectoryUpload.new(uri: root_uri)
        end

        def children
          @children ||= root.children.map do |child|
            if child.is_a?(DirectoryUpload)
              self.class.new(root_uri: child.uri)
            else
              child
            end
          end
        end

        def trees
          @trees ||= children.select { |c| c.is_a?(self.class) }
        end

        def leaf_nodes
          @leaf_nodes ||= children.select { |c| c.is_a?(FileUpload) }
        end

        def flatten
          @flatten ||= begin
                         values = []
                         children.each do |child|
                          if child.is_a?(DirectoryUpload)
                            values += child.flatten
                          else
                            values << child
                          end
                         end
                         values
                       end
        end
      end

      class Pages
        attr_reader :elements, :page_length

        def initialize(pages: nil, elements: [], page_length: Page::DEFAULT_LENGTH)
          @pages = pages
          @elements = elements
          @page_length = page_length
        end

        def pages
          @pages ||= begin
                       slices = elements.each_slice(page_length)
                       slices.map do |slice|
                         Page.new(elements: slice)
                       end
                     end
        end

        delegate :empty?, to: :pages
        delegate :first, to: :pages
        delegate :last, to: :pages
        delegate :length, to: :pages
      end

      class Page
        DEFAULT_LENGTH = 25
        attr_reader :elements

        def initialize(elements:)
          @elements = elements
        end

        delegate :empty?, to: :elements
        delegate :first, to: :elements
        delegate :last, to: :elements
        delegate :length, to: :elements
      end

      # Constructor
      # @param options [Hash] configuration for the driver
      def initialize(**options)
        @root_path = options[:root_path]

        super(**options)
      end

      def resolve(uri:)
        resource_tree = ResourceTree.new(root_uri: uri)
        Pages.new(elements: resource_tree.flatten)
      end

      def root_path
        @root_path ||= configuration[:home]
      end

      # Retrieve the contents of a directory
      # @param path [String] the path to a file system resource
      # @return [Array<BrowseEverything::RemoteFile>]
      def contents(path: nil)
        path ||= root_path
        full_path = Pathname.new("#{root_path}#{path}")
        uri = "file://#{full_path}"

        resolve(uri: uri)
      end

      ####

      def icon
        'file'
      end

      def validate_config
        if remote_root_path.blank?
          raise(
            BrowseEverything::Driver::ConfigurationError,
            'FileSystem driver requires a :home argument'
          )
        end
      end

      def current_page
        pages.last
      end

      def paginate(remote_resource)
        current_page << remote_resource
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
        Pathname.new(File.expand_path(path)).relative_path_from(Pathname.new(configuration[:home]))
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
