class AdminController < ApplicationController
  def set_bank
    account = Account.find_by(trigramme: params[:trigramme].upcase)
    fail TdbException, 'Trigramme doesn\'t exists' if account.nil?
    fail TdbException, 'Trigramme is not a binet' unless account.binet?
    require_admin!(:banque_binet)
    session[:bank_id] = account.id
    session[:bank] = account.trigramme
    redirect_to_trigramme(account.trigramme)
  end
end
