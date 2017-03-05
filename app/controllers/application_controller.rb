class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  http_basic_authenticate_with name: ENV['http_basic_name'], password: ENV['http_basic_password'], except: :index

  def index
  end
end
