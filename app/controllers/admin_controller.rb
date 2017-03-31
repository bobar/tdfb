require 'digest/md5'

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

  def index
    require_admin!(:gestion_admin)
    @admins = Admin.joins(:account).includes(:account).includes(:right).order('admins.permissions, accounts.promo').all
    @rights = Right.order(:permissions).all
  end

  def create_admin
    account = Account.find_by(trigramme: params[:trigramme])
    fail TdbException, 'Trigramme doesn\'t exists' unless account
    fail TdbException, 'Passwords don\'t match' unless params[:password] == params[:password_again]
    Admin.create(id: account.id, permissions: params[:permissions], passwd: Digest::MD5.hexdigest(params[:password]))
    redirect_to_url '/admins'
  end

  def delete_admin
    require_admin!(:gestion_admin)
    Admin.find(params[:id]).delete
    redirect_to_url '/admins'
  end

  def update_rights
    require_admin!(:gestion_admin)
    Right.transaction do
      Right.all.each do |right|
        right.update(
          Right.right_columns.map do |col|
            [col, (params["#{right.permissions}.#{col}"] == 'on')]
          end.to_h,
        )
      end
    end
    redirect_to_url '/admins'
  end

  def create_rights
    require_admin!(:gestion_admin)
    Right.create(nom: params[:name].strip, permissions: 1 + Right.maximum(:permissions).to_i)
    redirect_to_url '/admins'
  end

  def delete_rights
    require_admin!(:gestion_admin)
    permissions = params[:permissions].to_i
    fail TdbException, 'Those rights are in use' if Admin.exists?(permissions: permissions)
    Right.where(permissions: permissions).delete_all
    redirect_to_url '/admins'
  end
end
