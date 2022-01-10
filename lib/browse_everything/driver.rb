# frozen_string_literal: true

module BrowseEverything
  module Driver
    # Configuration errors
    class ConfigurationError < RuntimeError; end

    autoload :Page,        'browse_everything/driver/page'
    autoload :Base,        'browse_everything/driver/base'
    # autoload :Box,         'browse_everything/driver/box'
    # autoload :Dropbox,     'browse_everything/driver/dropbox'
    autoload :FileSystem,  'browse_everything/driver/file_system'
    # autoload :GoogleDrive, 'browse_everything/driver/google_drive'
    # autoload :S3,          'browse_everything/driver/s3'

    class << self
      def configuration_path
        Rails.root.join('config', 'browse_everything_providers.yml')
      end

      def parse_configuration
        config_file_content = File.read(configuration_path)
        config_file_template = ERB.new(config_file_content)
        config_values = YAML.safe_load(config_file_template.result, [Symbol])
        config = ActiveSupport::HashWithIndifferentAccess.new(config_values)
        config.deep_symbolize_keys
      end

      def configuration
        begin
          @config = parse_configuration
        rescue Errno::ENOENT
          Rails.logger.warn("browse_everything_providers.yml configuration file not found at #{configuration_path}")
          @config = ActiveSupport::HashWithIndifferentAccess.new({})
        end
      end

      def build_driver(key:, **options)
        case key
        when :file_system
          FileSystem.new(**options)
        else
          raise(NotImplementedError, "Data source driver not supported for #{key}")
        end
      end

      def all
        @all ||= begin
                   configuration.map do |key, options|
                     build_driver(key: key, **options)
                   end
                 end
      end
    end
  end
end
