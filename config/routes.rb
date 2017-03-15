Rails.application.routes.draw do
  root 'application#index'

  get 'index' => 'application#index'
  get 'switch_theme' => 'application#switch_theme'

  controller :account, path: 'account' do
    get 'search' => :search
    get ':id' => :show
    get 'exists/:trigramme' => :exists
    post 'log/:id' => :log
    post 'credit/:id' => :credit
    post 'clopes/:id' => :clopes
    post 'nickname/:id' => :set_nickname
    post 'trigramme/:id' => :set_trigramme
    post 'transfer/:id' => :transfer
  end
end
