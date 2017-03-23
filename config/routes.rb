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
    post 'log/:id' => :log
    post 'credit/:id' => :credit
    post 'clopes/:id' => :clopes
    post 'transfer/:id' => :transfer
  end
end
