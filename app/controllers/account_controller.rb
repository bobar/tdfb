class AccountController < ApplicationController
  def search
    render json: Account.search(params[:term]).map { |a| { label: "#{a.trigramme} - #{a.name}", value: a.id } }
  end

  def find
    @account = Account.find(params[:id])
  end
end
