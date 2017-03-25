Rails.application.routes.draw do
  root 'application#index'

  get 'index' => 'application#index'
  get 'login' => 'application#login'
  get 'switch_theme' => 'application#switch_theme'

  controller :account, path: 'account' do
    get 'search' => :search
    get ':id' => :show
    post ':id' => :update
    get 'exists/:trigramme' => :exists
    get 'details/:trigramme' => :details
    post 'log/:id' => :log
    post 'credit/:id' => :credit
    post 'clopes/:id' => :clopes
    post 'transfer/:id' => :transfer
  end

  controller :group_log, path: 'group_log' do
    get '/' => :index
    post '/' => :log
  end
end
