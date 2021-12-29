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
  end
end
