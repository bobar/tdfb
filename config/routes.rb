Rails.application.routes.draw do
  root 'application#index'

  get 'index' => 'application#index'
  get 'login' => 'application#login'
  get 'switch_theme' => 'application#switch_theme'
  post 'feedback' => 'application#create_github_issue'

  controller :account, path: 'account' do
    get 'binets' => :binets
    get 'search' => :search
    get 'new' => :new
    get 'filter' => :filter
    get 'unknown/:trigramme' => :unknown_account
    get 'exists/:trigramme' => :exists
    get 'details/:trigramme' => :details
    get ':id' => :show
    post 'create' => :create
    post 'cancel_transaction' => :cancel_transaction
    post 'log/:id' => :log
    post 'credit/:id' => :credit
    post 'clopes/:id' => :clopes
    post 'transfer/:id' => :transfer
    post 'fkz_refresh/:id' => :fkz_refresh
    post ':id' => :update
    delete ':id' => :delete
  end

  controller :user, path: 'user' do
    get 'search' => :search
  end

  controller :group_log, path: 'group_log' do
    get '/' => :index
    post '/' => :log
  end

  controller :admin do
    post 'bank/:trigramme' => :set_bank
    get 'admins' => :index
    post 'admin/change_password' => :change_password
    post 'rights' => :update_rights
    post 'rights/new' => :create_rights
    post 'admin/edit/:id' => :update_admin
    post 'admin/new' => :create_admin
    delete 'admin/:id' => :delete_admin
    delete '/rights' => :delete_rights
  end

  controller :frankiz, path: 'frankiz' do
    get '/' => :index
    post '/stop' => :stop
    post '/refresh_promo' => :refresh_promo
  end

  controller :clopes, path: 'clopes' do
    get 'administration' => :administration
    post 'edit/:id' => :update
    post 'new' => :create
    post 'reset_quantities' => :reset_quantities
    delete ':id' => :delete
  end

  controller :file_import, path: 'file_import' do
    get '/' => :index
    post '/' => :read_file
    post 'submit' => :submit
    get 'cancelled_file' => :cancelled_file
  end
end
