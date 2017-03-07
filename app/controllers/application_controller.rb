require 'digest/md5'

class ApplicationController < ActionController::Base
  AUTH_EXPIRES = 20.seconds

  http_basic_authenticate_with name: ENV['http_basic_name'], password: ENV['http_basic_password'] if Rails.env.production?

  protect_from_forgery with: :exception
  before_action :load_bank

  rescue_from TdbException do |mes|
    render json: mes.to_h, status: 400
  end

  rescue_from AuthException do
    # Just to stop propagation
  end

  def index
    cookies[:bank_id] = 1
    cookies[:bank] = 'BOB'
  end

  private

  def load_bank
    cookies[:bank_id] ||= 1
    cookies[:bank] ||= 'BOB'
    @bank = Account.find(cookies[:bank_id])
  end

  def require_admin!
    return true if Rails.env.production?
    if session[:expire_at].nil? || session[:expire_at] < Time.current
      session[:expire_at] = Time.current + AUTH_EXPIRES
      request_http_basic_authentication
      fail AuthException
    else
      authenticate_with_http_basic do |username, password|
        (admin = Admin.joins(:account).find_by(accounts: { trigramme: username })) &&
          (Digest::MD5.hexdigest(password) == admin.passwd) &&
          (session[:expire_at] = Time.current + AUTH_EXPIRES) &&
          (@admin = admin)
      end || (request_http_basic_authentication && fail(AuthException))
    end
  end
end
