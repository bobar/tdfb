class UserController < ApplicationController
  def search
    users = User.search(params[:term]).map do |a|
      a.as_json.merge(label: a.autocomplete_text, first_name: a.first_name, last_name: a.last_name, status: a.status)
    end
    render json: users
  end
end
