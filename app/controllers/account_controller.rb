class AccountController < ApplicationController
  def search
    render json: Account.search(params[:term]).map { |a| { label: "#{a.trigramme} - #{a.first_name} #{a.name}", value: a.id } }
  end

  def show
    @account = Account.find(params[:id])
  end

  def log
    @account = Account.find(params[:id])
    amount = (100 * params[:amount]).to_i
    @account.log(amount, cookies[:bank_id].to_i)
  end
end
