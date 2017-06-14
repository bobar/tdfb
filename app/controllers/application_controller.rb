require 'digest/md5'

class ApplicationController < ActionController::Base
  AUTH_EXPIRES = 20.seconds
  FORCE_AUTH = %w(supprimer_tri banque_binet gestion_clopes gestion_admin).freeze

  around_action :production_auth if Rails.env.production? # We don't want anyone being able to read from Heroku

  protect_from_forgery with: :exception
  before_action :load_bank

  rescue_from TdbException do |mes|
    render json: mes.to_h, status: 400
  end

  rescue_from AuthException do
    # Will be reset after first successfull login. If this delay is too short, what happens is than the pop-up appears and
    # when the user finishes typing, the delay has already expired, and the authentication attempt will be rejected whether the
    # credentials are correct or not.
    session[:expire_at] = Time.current + 24.hours
    request_http_basic_authentication
  end

  rescue_from ActionController::InvalidAuthenticityToken do
    render json: '', status: 499
  end

  def index
    @chart_globals = Chart.theme(session['chart_theme'], session['theme'])
    @transactions_volume = Chart.transactions_volume(7, @bank)
    @best_consumers = Chart.best_consumers(7, @bank)
    @scatter_plot = Chart.scatter_plot
    @heat_map = Chart.heat_map(7, @chart_globals)
    @birthdays = Account.x.where('birthdate LIKE ?', Date.current.strftime('%%-%m-%d')).order(promo: :desc)
  end

  def login
    session[:expire_at] = Time.current + 24.hours # To avoid first auth bug
    render layout: false
  end

  def switch_theme
    session['theme'] = params['theme'] if params['theme']
    session['theme'] = nil if params['theme'] == 'bootstrap'
    session['chart_theme'] = params['chart_theme'] if params['chart_theme']
    redirect_to :back
  end

  def create_github_issue
    client = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
    body = params[:feedback_body]
    body += "\n\nName: #{params[:name]}\nEmail: #{params[:email]}"
    client.create_issue('bobar/tdfb', params[:feedback_title].to_s, body)
    redirect_to :back
  end

  private

  def redirect_to_index
    redirect_to_url '/'
  end

  def redirect_to_url(url)
    respond_to do |format|
      format.html { redirect_to url }
      format.js { return render text: "window.location.href = '#{url}';" }
    end
  end

  def redirect_to_trigramme(trigramme)
    redirect_to_url "/account/#{trigramme}"
  end

  def load_bank
    session[:bank_id] ||= Account::DEFAULT_BANK_ID
    session[:bank] ||= Account::DEFAULT_BANK_TRIGRAMME
    @bank = Account.find(session[:bank_id])
  end

  def require_admin!(right, force: false)
    @auth_called = true
    force ||= FORCE_AUTH.include?(right.to_s)

    if force
      # If force = true, we want to enforce the user to type their password, indepently of what happened before,
      # so we're gonna fail and store the current action in the session so that next time we have a match and we succeed.
      # We need to do so before the expire condition in order not to request auth twice.
      unless controller_path == session[:force_auth_controller] && action_name == session[:force_auth_action]
        session[:force_auth_controller] = controller_path
        session[:force_auth_action] = action_name
        fail AuthException
      end
    end

    if session[:expire_at].nil? || session[:expire_at] < Time.current
      fail AuthException
    end

    if request.headers['Authorization'].nil? || request.headers['Authorization'] == ''
      # For some reason chrome sometimes doesn't send the header even if auth was done earlier.
      fail AuthException
    end

    authenticate_with_http_basic do |username, password|
      @admin = Admin.joins(:account).joins(:right).includes(:right).find_by(accounts: { trigramme: username })
      auth = false
      if @admin.nil?
        response.header['auth_reason'] = I18n.t(:unauthorized_unknown_admin, trigramme: username)
      elsif Digest::MD5.hexdigest(password) != @admin.passwd
        response.header['auth_reason'] = I18n.t(:unauthorized_wrong_password, trigramme: username)
      elsif !@admin.right[right]
        response.header['auth_reason'] = I18n.t(:unauthorized_insufficient_rights)
      else
        auth = true
      end
      if auth
        session[:expire_at] = Time.current + AUTH_EXPIRES
        session[:force_auth_controller] = nil
        session[:force_auth_action] = nil
      end
      auth
    end || fail(AuthException)
  end

  def production_auth
    yield
    require_admin!(:log_eleve) unless @auth_called
  end
end
