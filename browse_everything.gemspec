# frozen_string_literal: true
require_relative "lib/browse_everything/version"

Gem::Specification.new do |spec|
  spec.name        = "browse_everything"
  spec.version     = BrowseEverything::VERSION
  spec.authors     = ['Jessie Keck', 'Michael B. Klein', 'Thomas Scherz', 'Xiaoming Wang', 'James R. Griffin III']
  spec.email       = ['jkeck@stanford.edu', 'mbklein@gmail.com', 'scherztc@ucmail.uc.edu', 'xw5d@virginia.edu', "jrg5@princeton.edu"]
  spec.homepage    = "https://github.com/samvera/browse-everything"
  spec.summary     = 'AJAX/Rails engine file browser for cloud storage services'
  spec.description = 'AJAX/Rails engine file browser for cloud storage services'
  spec.license     = "Apache 2"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/samvera/browse-everything/blob/main/LICENSE.txt"

  spec.files = Dir["{app,config,db,lib}/**/*", "LICENSE.txt", "Rakefile", "README.md"]

  spec.add_dependency "bootstrap-sass", "~> 3.0"
  spec.add_dependency "ejs", "~> 1.1"
  spec.add_dependency "jquery-rails", "~> 4.0"
  spec.add_dependency "rails", "~> 6.1.4", ">= 6.1.4.4"
  spec.add_dependency 'sass-rails', '~> 5.0'

  spec.add_development_dependency 'bixby', '~> 3.0.2', '>= 3.0.2'
  spec.add_development_dependency 'database_cleaner-active_record', '~> 2.0.1', '>= 2.0.1'
  spec.add_development_dependency 'pry-byebug', '~> 3.9.0', '>= 3.9.0'
  spec.add_development_dependency 'rails-controller-testing', '~> 1.0.5', '>= 1.0.5'
  spec.add_development_dependency 'rspec-rails', '~> 5.0.2', '>= 5.0.2'
  spec.add_development_dependency 'rspec', '~> 3.10.0', '>= 3.10.0'
  spec.add_development_dependency 'simplecov', '~> 0.21.2', '>= 0.21.2'
end
