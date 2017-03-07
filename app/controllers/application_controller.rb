require 'digest/md5'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate!

  rescue_from TdbException do |mes|
    render json: mes.to_h, status: 400
  end

  def index
    cookies[:bank_id] = 1
    cookies[:bank] = 'BOB'
  end

  private

  def unauthorized!
    return render text: 'Unauthorized', status: 401 if cookies[:logged_in].nil? || Time.zone.parse(cookies[:logged_in]) < Time.current - 30.seconds
  end

  def authenticate!
    authenticate_or_request_with_http_basic do |username, password|
      unauthorized!
      admin = Admin.joins(:account).find_by(accounts: { trigramme: username })
      admin && Digest::MD5.hexdigest(password) == admin.passwd && cookies[:logged_in] = Time.current
    end
  end
end
