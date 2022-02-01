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
        attr_reader :local_path, :parent, :uri

        def initialize(**options)
          unresolved = options[:uri]
          @uri_path = unresolved.to_s.gsub('file://', '')
          raise(StandardError, "Attempted to resolve an empty file system path") if @uri_path.blank?

          expanded_resource_path = File.expand_path(@uri_path)
          @local_path = Pathname.new(expanded_resource_path)

          @parent = options[:parent]
          @uri = "file://#{local_path}"
        end

        delegate :basename, to: :local_path

        def attributes
          {
            basename: basename,
            parent: parent,
            path: path
          }
        end

        def as_json(*_options)
          attributes
        end

        def path
          @path ||= begin
                      leaf_path = if !parent.nil?
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
        alias to_a flatten

        def attributes
          {
            root: root.attributes,
            children: children.map(&:attributes)
          }
        end

        delegate :as_json, to: :attributes
        delegate :basename, to: :root
        delegate :uri, to: :root
      end

      class Pages
        include Enumerable
        attr_reader :pages, :page_length

        def self.build(resource_tree:, page_length: Page::DEFAULT_LENGTH)
          elements = [resource_tree] + resource_tree.to_a
          slices = elements.each_slice(page_length)
          pages = slices.map do |slice|
            Page.new(elements: slice)
          end

          new(pages: pages, page_length: page_length)
        end

        def initialize(pages: nil, elements: [], page_length: Page::DEFAULT_LENGTH)
          @pages = pages
          @elements = elements
          @page_length = page_length
        end

        def each
          pages.each do |page|
            yield page
          end
        end

        delegate :empty?, to: :pages
        # delegate :first, to: :pages
        delegate :last, to: :pages
        delegate :length, to: :pages
        delegate :to_a, to: :pages

        def attributes
          to_a
        end

        def as_json(*_options)
          attributes
        end
      end

      class Page
        DEFAULT_LENGTH = 25

        include Enumerable
        attr_reader :elements

        def initialize(elements:)
          @elements = elements
        end

        def each
          elements.each do |element|
            yield element
          end
        end

        delegate :[], to: :elements
        delegate :empty?, to: :elements
        delegate :first, to: :elements
        delegate :last, to: :elements
        delegate :length, to: :elements
        delegate :to_a, to: :elements
      end

      attr_reader :root_path

      # Constructor
      # @param options [Hash] configuration for the driver
      def initialize(**options)
        home_option = options[:home]
        @root_path = File.expand_path(home_option) if home_option

        super(**options)
      end

      def resolve(uri:)
        resource_tree = ResourceTree.new(root_uri: uri)
        Pages.build(resource_tree: resource_tree)
      end

      # def root_path
      #  @root_path ||= begin
      #                   File.expand_path(configuration[:home])
      #                 end
      # end

      # Retrieve the contents of a directory
      # @param path [String] the path to a file system resource
      # @return [Pages]
      def browse(path: nil)
        full_path = if path.nil?
                      Pathname.new(root_path)
                    else
                      joined = File.join(root_path, path)
                      Pathname.new(joined)
                    end
        uri = "file://#{full_path}"

        resolve(uri: uri)
      end
      alias contents browse

      #
      ## Legacy Methods (to be removed)

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
