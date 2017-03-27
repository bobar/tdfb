class ClopesController < ApplicationController
  def administration
    @clopes = Clope.all
  end

  def update
    require_admin!(:gestion_clopes)
    @clope = Clope.find(params[:id])
    to_update = {}
    [:marque, :prix, :quantite].each do |item|
      to_update[item] = params[item].strip if params[item]
    end
    @clope.update(to_update)
    redirect_to action: :administration
  end

  def create
    require_admin!(:gestion_clopes)
    Clope.create(marque: params[:marque], prix: params[:prix], quantite: params[:quantite])
    redirect_to action: :administration
  end
end
