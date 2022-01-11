# frozen_string_literal: true

module BrowseEverything
  module Driver
    # Abstract class for provider classes
    class Base
      include BrowseEverything::Engine.routes.url_helpers

      # Provide accessor and mutator methods for @token and @code
      # attr_accessor :token, :code
      attr_reader :id

      # Constructor
      # @param options [Hash] configuration for the driver
      def initialize(**options)
        @id = options.delete(:id)
        @options = options

        raise(StandardError, "Invalid configuration options: #{options}") unless configuration.valid?
      end

      def attributes
        {
          id: id
        }
      end

      def as_json
        attributes.to_json
      end

      class Configuration < OpenStruct
        def valid?
          true
        end
      end

      def self.configuration_class
        Configuration
      end

      def self.build_configuration(**options)
        configuration_class.new(**options)
      end

      def configuration
        @configuration ||= self.class.build_configuration(**@options)
      end

      delegate :name, to: :configuration

      def resolve(*); end

      ####

      # Generate the key for the driver
      # @return [String]
      def key
        class_name = self.class.name
        segments = class_name.split(/::/)
        last_segment = segments.last
        last_segment.underscore
      end

      # Generate the icon markup for the driver
      # @return [String]
      def icon
        'unchecked'
      end

      # Generate the name for the driver
      # @return [String]

      # Abstract method
      def contents(*_args)
        []
      end

      # Generate the link for a resource at a given path
      # @param path [String] the path to the resource
      # @return [Array<String, Hash>]
      def link_for(path)
        [path, { file_name: File.basename(path) }]
      end

      # Abstract method
      def authorized?
        false
      end

      # Abstract method
      def auth_link(*_args)
        []
      end

      # Abstract method
      def connect(*_args)
        nil
      end

      private

      # Generate the options for the Rails URL generation for API callbacks
      # remove the script_name parameter from the url_options since that is causing issues
      #   with the route not containing the engine path in rails 4.2.0
      # @return [Hash]
      def callback_options
        options = config.to_hash
        options.deep_symbolize_keys!
        options[:url_options].reject { |k, _v| k == :script_name }
      end

      # Generate the URL for the API callback
      # @return [String]
      def callback
        connector_response_url(callback_options)
      end
    end
  end
end
