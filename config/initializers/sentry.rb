Raven.configure do |config|
  config.dsn = 'https://27660d4e6a794beaacb08a6e987ef257:9139365af07b45ebba4e526a36d97b74@sentry.io/175369'
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  config.environments = %w(production bob)
end
