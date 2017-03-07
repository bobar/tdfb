class TransactionController < ApplicationController
  def log
    @account = Account.find(params[:account_id])
    amount = (100 * params[:amount]).to_i
    @account.log(amount, cookies[:bank_id].to_i)
  end
end
