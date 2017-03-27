class ClopesController < ApplicationController
  def administration
    @clopes = Clope.order(quantite: :desc).all
    @chart_globals = Chart.theme(session['theme'])
    @cigarettes_volume = Chart.cigarettes_volume
    @cigarettes_turnover = Chart.cigarettes_turnover
  end

  def update
    require_admin!(:gestion_clopes)
    @clope = Clope.find(params[:id])
    to_update = {}
    to_update[:marque] = params[:marque].strip if params[:marque]
    to_update[:prix] = (100 * params[:prix].to_f).to_i if params[:prix]
    @clope.update(to_update)
    redirect_to :administration
  end

  def create
    require_admin!(:gestion_clopes)
    Clope.create(marque: params[:marque], prix: (100 * params[:prix].to_f).to_i, quantite: 0)
    redirect_to :administration
  end

  def reset_quantities
    require_admin!(:gestion_clopes)
    Clope.update_all(quantite: 0)
    redirect_to :administration
  end

  def delete
    require_admin!(:gestion_clopes)
    Clope.find(params[:id]).delete
    redirect_to :administration
  end
end
