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
    config.i18n.default_locale = :fr
    config.filter_parameters << :password

    config.assets.js_compressor = :uglifier
    config.assets.compile = true
    config.assets.digest = true
    config.assets.raise_runtime_errors = true

    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address:              'smtp.gmail.com',
      port:                 587,
      domain:               'gmail.com',
      user_name:            'bobar.tdb@gmail.com',
      password:             ENV['GMAIL_PASSWORD'],
      authentication:       'plain',
      enable_starttls_auto: true,
    }
    config.action_mailer.perform_deliveries = true
    config.action_mailer.raise_delivery_errors = true
  end
end
