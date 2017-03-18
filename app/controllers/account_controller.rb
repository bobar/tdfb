class AccountController < ApplicationController
  def search
    render json: Account.search(params[:term]).map { |a| { label: a.autocomplete_text, value: a.id, full_name: a.full_name } }
  end

  def show
    @account = Account.find(params[:id]) if params[:id] =~ /^\d+$/
    @account ||= Account.find_by(trigramme: params[:id].upcase) if params[:id].size == 3
    return redirect_to controller: :application, action: :index unless @account
  end

  def exists
    render json: Account.where(trigramme: params[:trigramme].upcase).exists?
  end

  def log
    @account = Account.find(params[:id])
    amount = params[:amount].to_f
    fail TdbException, 'Amount must be positive!' if amount < 0
    require_admin! if amount > 20 # 20 euros
    Transaction.log(@account, @bank, amount, comment: params[:comment], admin: @admin)
    render_redirect_to
  end

  def credit
    @account = Account.find(params[:id])
    amount = params[:amount].to_f
    fail TdbException, 'Amount must be positive!' if amount < 0
    require_admin!
    comment = params[:commit]
    comment += " - #{params[:comment]}" if params[:comment] && !params[:comment].empty?
    Transaction.log(@account, @bank, -amount, comment: comment, admin: @admin)
    render_redirect_to
  end

  def clopes
    @account = Account.find(params[:id])
    clope = Clope.find(params[:clope_id])
    quantity = params[:quantity].to_i
    require_admin! if quantity * clope.prix > 2000
    clope.sell(@account, quantity, admin: @admin)
    render_redirect_to
  end

  def update
    @account = Account.find(params[:id])
    require_admin!
    to_update = {}
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
    require_admin!
    receiver = Account.find_by(trigramme: params[:receiver].upcase)
    fail TdbException, "Trigramme #{params[:receiver].upcase} is unknown" unless receiver
    fail TdbException, 'Sender and recipient are the same' if receiver.id == @account.id
    Transaction.log(@account, receiver, amount, comment: params[:comment], admin: @admin)
    render_redirect_to
  end

  private

  def render_redirect_to
    respond_to do |format|
      format.html { redirect_to action: :show }
      format.js { return render text: 'location.reload();' }
    end
  end
end
