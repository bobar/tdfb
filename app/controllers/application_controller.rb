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

  def switch_theme
    session['theme'] = params['theme']
    redirect_to :back
  end

  private

  def load_bank
    cookies[:bank_id] ||= 1
    cookies[:bank] ||= 'BOB'
    @bank = Account.find(cookies[:bank_id])
  end

  def require_admin!(right)
    return true if Rails.env.production?
    authenticate_with_http_basic do |username, password|
      if session[:expire_at].nil? || session[:expire_at] < Time.current
        session[:expire_at] = Time.current + 24.hours
        # Will be reset after first successfull login. If this delay is too short, what happens is than the pop-up appears and
        # when the user finishes typing, the delay has already expired, and the authentication attempt will be rejected whether the
        # credentials are correct or not.
        request_http_basic_authentication
        fail AuthException
      end
      @admin = Admin.joins(:account).includes(:right).find_by(accounts: { trigramme: username })
      fail TdbException, "Unknown admin with trigramme #{username}" if @admin.nil?
      fail TdbException, "Wrong password for #{username}" unless Digest::MD5.hexdigest(password) == @admin.passwd
      fail TdbException, "You don't have the right to do this" unless @admin.right[right]
      session[:expire_at] = Time.current + AUTH_EXPIRES
      true
    end || (request_http_basic_authentication && fail(AuthException))
  end
end
