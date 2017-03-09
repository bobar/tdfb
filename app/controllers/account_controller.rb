class AccountController < ApplicationController
  def search
    render json: Account.search(params[:term]).map { |a| { label: "#{a.trigramme} - #{a.first_name} #{a.name}", value: a.id } }
  end

  def show
    @account = Account.find(params[:id])
  end

  def log
    @account = Account.find(params[:id])
    amount = params[:amount].to_f
    fail 'Amount must be positive!' if amount < 0
    require_admin! if amount > 20 # 20 euros
    Transaction.log(@account, @bank, amount, comment: params[:comment], admin: @admin)
    render_redirect_to
  end

  def credit
    @account = Account.find(params[:id])
    amount = params[:amount].to_f
    fail 'Amount must be positive!' if amount < 0
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

  private

  def render_redirect_to
    respond_to do |format|
      format.html { redirect_to action: :show }
      format.js { return render text: 'location.reload();' }
    end
  end
end
