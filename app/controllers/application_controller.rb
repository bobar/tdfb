require 'digest/md5'

class ApplicationController < ActionController::Base
  AUTH_EXPIRES = 20.seconds
  FORCE_AUTH = %w(supprimer_tri banque_binet gestion_clopes gestion_admin).freeze

  include Chart

  before_action do
    require_admin!(:log_eleve) if Rails.env.production?
  end

  protect_from_forgery with: :exception
  before_action :load_bank

  rescue_from TdbException do |mes|
    render json: mes.to_h, status: 400
  end

  rescue_from AuthException do
    # Just to stop propagation
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
    IssueMailer.issue(params[:name], params[:email], params[:feedback_title], params[:feedback_body]).deliver_now
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
    session[:bank_id] ||= 1
    session[:bank] ||= 'BOB'
    @bank = Account.find(session[:bank_id])
  end

  def require_admin!(right, force: false)
    force ||= FORCE_AUTH.include?(right.to_s)

    authenticate_with_http_basic do |username, password|
      if session[:expire_at].nil? || session[:expire_at] < Time.current
        session[:expire_at] = Time.current + 24.hours
        # Will be reset after first successfull login. If this delay is too short, what happens is than the pop-up appears and
        # when the user finishes typing, the delay has already expired, and the authentication attempt will be rejected whether the
        # credentials are correct or not.
        request_http_basic_authentication
        fail AuthException
      end

      if force
        # If force = true, we want to enforce the user to type their password, indepently of what happened before,
        # so we're gonna fail and store the current action in the session so that next time we have a match and we succeed.
        unless controller_path == session[:force_auth_controller] && action_name == session[:force_auth_action]
          session[:force_auth_controller] = controller_path
          session[:force_auth_action] = action_name
          request_http_basic_authentication
          fail AuthException
        end
      end

      auth = false
      @admin = Admin.joins(:account).includes(:right).find_by(accounts: { trigramme: username })
      if @admin.nil?
        response.header['auth_reason'] = "Unknown admin with trigramme #{username}"
      elsif Digest::MD5.hexdigest(password) != @admin.passwd
        response.header['auth_reason'] = "Wrong password for #{username}"
      elsif !@admin.right[right]
        response.header['auth_reason'] = 'You don\'t have the right to do this'
      else
        session[:expire_at] = Time.current + AUTH_EXPIRES
        auth = true
      end
      if auth
        session[:force_auth_controller] = nil
        session[:force_auth_action] = nil
      end
      auth
    end || ((session[:expire_at] = Time.current + 24.hours) && request_http_basic_authentication && fail(AuthException))
  end
end
