# frozen_string_literal: true

module BrowseEverything
  module Driver
    # Configuration errors
    class ConfigurationError < RuntimeError; end

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

      def config_file_content
        File.read(configuration_path)
      end

      def config_file_template
        ERB.new(config_file_content)
      end

      def config_values
        YAML.safe_load(config_file_template.result, [Symbol])
      end

      def parse_configuration
        # config_file_content = File.read(configuration_path)
        # config_file_template = ERB.new(config_file_content)
        # config_values = YAML.safe_load(config_file_template.result, [Symbol])
        # config = ActiveSupport::HashWithIndifferentAccess.new(config_values)
        config_values.deep_symbolize_keys
      end

      def configuration
        @config = parse_configuration
      rescue Errno::ENOENT
        Rails.logger.warn("browse_everything_providers.yml configuration file not found at #{configuration_path}")
        @config = ActiveSupport::HashWithIndifferentAccess.new({})
      end

      def build(id:, **_options)
        options = { id: id }.merge(configuration[id])

        case id
        when :file_system
          FileSystem.new(**options)
        else
          raise(NotImplementedError, "Data source driver not supported for #{id}")
        end
      end

      def all
        @all ||= begin
                   configuration.map do |key, options|
                     build(id: key, **options)
                   end
                 end
      end
    end
  end
end
