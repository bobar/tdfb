require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(*Rails.groups)

module Tdfb
  class Application < Rails::Application
    config.time_zone = 'Europe/Paris'
    config.active_record.raise_in_transactional_callbacks = true
    config.active_record.default_timezone = :utc
    config.autoload_paths += ["#{config.root}/lib"]
  end
end
