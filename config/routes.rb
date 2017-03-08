Rails.application.routes.draw do
  root 'application#index'

  get 'index' => 'application#index'

  controller :account, path: 'account' do
    get 'search' => :search
    get ':id' => :show
    post 'log/:id' => :log
    post 'credit/:id' => :credit
    post 'clopes/:id' => :clopes
  end
end
