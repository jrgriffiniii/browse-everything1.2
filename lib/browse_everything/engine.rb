# frozen_string_literal: true
module BrowseEverything
  class Engine < ::Rails::Engine
    isolate_namespace BrowseEverything

    jquery_rails_path = Gem.loaded_specs['jquery-rails'].full_gem_path
    config.assets.paths << jquery_rails_path
    config.assets.paths << "#{jquery_rails_path}/vendor/assets/javascripts"

    bootstrap_sass_path = Gem.loaded_specs['bootstrap-sass'].full_gem_path
    config.assets.paths << bootstrap_sass_path
    config.assets.paths << "#{bootstrap_sass_path}/assets/stylesheets"
    config.assets.paths << "#{bootstrap_sass_path}/assets/javascripts"

    config.assets.precompile += %w( browse_everything/browse_everything.js )
  end
end
