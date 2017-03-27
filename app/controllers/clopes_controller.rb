class ClopesController < ApplicationController
  def administration
    @clopes = Clope.all
    @chart_globals = Chart.theme(session['theme'])
    @cigarettes_volume = Chart.cigarettes_volume
    @cigarettes_turnover = Chart.cigarettes_turnover
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

  def reset_quantities
    require_admin!(:gestion_clopes)
    Clope.all.update_all(quantite: 0)
    redirect_to action: :administration
  end
end
