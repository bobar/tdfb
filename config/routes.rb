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

  controller :clopes, path: 'clopes' do
    get 'administration' => :administration
    post 'edit/:id' => :update
    post 'new' => :create
  end

  controller :group_log, path: 'group_log' do
    get '/' => :index
    post '/' => :log
  end

  controller :admin do
    post 'bank/:trigramme' => :set_bank
  end

  controller :frankiz, path: 'frankiz' do
    get '/' => :index
    post '/crawl' => :start_crawling
  end
end
