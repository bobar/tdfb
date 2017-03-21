require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(*Rails.groups)

module Tdfb
  class Application < Rails::Application
    config.time_zone = 'Europe/Paris'
    config.active_record.raise_in_transactional_callbacks = true
    config.active_record.default_timezone = :utc
    config.autoload_paths += ["#{config.root}/lib"]
    config.log_level = ENV['LOG_LEVEL'].downcase.to_sym if ENV['LOG_LEVEL']
  end
end
