# Load the Rails application.
require File.expand_path('../application', __FILE__)

credential_file = Rails.root.join('config', 'credentials.yml')
if File.exist? credential_file
  credentials = YAML.load_file credential_file
  ENV.update credentials.stringify_keys
end

# Initialize the Rails application.
Rails.application.initialize!
