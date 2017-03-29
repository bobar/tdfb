class AccountController < ApplicationController
  def search
    render json: Account.search(params[:term]).map { |a| { label: a.autocomplete_text, value: a.id, full_name: a.full_name } }
  end

  def show
    @account = Account.find(params[:id]) if params[:id] =~ /^\d+$/
    @account ||= Account.find_by(trigramme: params[:id].upcase) if params[:id].size == 3
    return redirect_to controller: :application, action: :index unless @account
    @transactions = Transaction.where(id: @account.id)
      .includes(:receiver)
      .includes(:administrator)
      .order(date: :desc)
      .paginate(page: params[:page])
  end

  def exists
    render json: Account.where(trigramme: params[:trigramme].upcase).exists?
  end

  def details
    account = Account.find_by(trigramme: params[:trigramme].upcase)
    return render json: nil if account.nil?
    render json: account.as_json.merge!(display_text: account.autocomplete_text(with_trigramme: false))
  end

  def log
    @account = Account.find(params[:id])
    amount = params[:amount].to_f
    fail TdbException, 'Amount must be positive!' if amount < 0
    require_admin!(:log_eleve) if amount > 20 || (!@account.x_platal? && @account.budget < amount)
    Transaction.log(@account, @bank, amount, comment: params[:comment], admin: @admin)
    render_redirect_to
  end

  def credit
    @account = Account.find(params[:id])
    amount = params[:amount].to_f
    fail TdbException, 'Amount must be positive!' if amount < 0
    require_admin!(:credit)
    comment = params[:commit]
    comment += " - #{params[:comment]}" if params[:comment] && !params[:comment].empty?
    Transaction.log(@account, @bank, -amount, comment: comment, admin: @admin)
    render_redirect_to
  end

  def clopes
    @account = Account.find(params[:id])
    clope = Clope.find(params[:clope_id])
    quantity = params[:quantity].to_i
    total_price = quantity * clope.euro_price # Clopes price is in cents!
    require_admin!(:log_eleve) if total_price || (!@account.x_platal? && @account.budget < total_price)
    clope.sell(@account, quantity, admin: @admin)
    render_redirect_to
  end

  def update
    @account = Account.find(params[:id])
    require_admin!(:modifier_tri)
    to_update = {}
    if params[:picture]
      ext = File.extname(params[:picture].tempfile)
      Dir[Rails.root.join('app', 'assets', 'images', 'accounts', "#{@account.id}.*")].each { |f| File.delete f }
      path = Rails.root.join('app', 'assets', 'images', 'accounts', "#{@account.id}#{ext}")
      File.open(path, 'wb') { |f| f.write params[:picture].read }
      to_update[:picture] = path.to_s
    end
    to_update[:nickname] = params[:nickname].strip if params[:nickname] && !params[:nickname].empty?
    to_update[:trigramme] = params[:trigramme].strip.upcase if params[:trigramme] && !params[:trigramme].empty?
    to_update[:status] = params[:status] if params[:status]
    ActiveRecord::Base.transaction do
      Transaction.account_update(@account, to_update, admin: @admin)
      @account.update(to_update)
    end
    render_redirect_to
  end

  def transfer
    @account = Account.find(params[:id])
    amount = params[:amount].to_f
    fail TdbException, 'Amount must be positive!' if amount < 0
    require_admin!(:transfert)
    receiver = Account.find_by(trigramme: params[:receiver].upcase)
    fail TdbException, "Trigramme #{params[:receiver].upcase} is unknown" unless receiver
    fail TdbException, 'Sender and recipient are the same' if receiver.id == @account.id
    Transaction.log(@account, receiver, amount, comment: params[:comment], admin: @admin)
    render_redirect_to
  end

  def new
  end

  def create
    require_admin!(:creer_tri)
    account = Account.create(
      trigramme: params[:trigramme].upcase,
      frankiz_id: params[:frankiz_id],
      name: params[:name],
      first_name: params[:first_name],
      nickname: params[:nickname] || '',
      birthdate: params[:birthdate],
      casert: params[:casert] || '',
      status: params[:status],
      promo: params[:promo],
      mail: params[:email] || '',
      balance: (100 * params[:balance].to_f).to_i,
      picture: '',
    )
    redirect_to_trigramme(account.id)
  end

  def binets
    last_transactions = Transaction.group(:id).maximum(:date)
    binets = Account.binet.order(balance: :desc).map do |bin|
      next if bin.id == 1 || bin.balance == 0
      {
        full_name: bin.full_name,
        trigramme: bin.trigramme,
        budget: bin.budget,
        last_transaction: last_transactions[bin.id],
      }
    end.compact
    @binets_positive = binets.select { |b| b[:budget] > 0 }
    @binets_negative = binets.select { |b| b[:budget] < 0 }.reverse!
  end

  def filter
    @accounts = Account.all
    @columns = Account.columns.map(&:name)
    @visible_columns = %w(trigramme name first_name casert promo balance)
  end

  private

  def render_redirect_to
    respond_to do |format|
      format.html { redirect_to action: :show }
      format.js { return render text: 'location.reload();' }
    end
  end
end
