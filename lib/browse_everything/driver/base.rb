# frozen_string_literal: true

module BrowseEverything
  module Driver
    # Abstract class for provider classes
    class Base
      include BrowseEverything::Engine.routes.url_helpers

      # Provide accessor and mutator methods for @token and @code
      # attr_accessor :token, :code

      # Constructor
      # @param options [Hash] configuration for the driver
      def initialize(**options)
        @options = options

        validate_config
      end

      def build_config
        ActiveSupport::HashWithIndifferentAccess.new(@options)
      end

      # Ensure that the configuration Hash has indifferent access
      # @return [ActiveSupport::HashWithIndifferentAccess]
      def config
        @config ||= build_config
      end

      # Abstract method
      def validate_config; end

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
      def name
        @name ||= (config[:name] || key.titleize)
      end

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
