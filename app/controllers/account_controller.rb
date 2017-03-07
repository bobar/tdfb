class AccountController < ApplicationController
  def search
    render json: Account.search(params[:term]).map { |a| { label: "#{a.trigramme} - #{a.first_name} #{a.name}", value: a.id } }
  end

  def show
    @account = Account.find(params[:id])
  end

  def log
    @account = Account.find(params[:id])
    amount = (100 * params[:amount].to_f).to_i
    require_admin! if amount < 0 || amount > 2000 # 20 euros
    Transaction.log(@account, @bank, amount, comment: params[:comment], admin: @admin)
    redirect_to action: :show
  end
end
