Rails.application.routes.draw do
  get 'password_resets/new'
  get 'password_resets/edit'
  root   'static_pages#home'
  get    '/help',    to: 'static_pages#help'
  get    '/about',   to: 'static_pages#about'
  get    '/contact', to: 'static_pages#contact'
  get    '/signup',  to: 'users#new'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  
  # 自動的にRailsアプリケーションがRESTful URI に応答する
  # ユーザーidが含まれているURLをGETする
  resources :users do
    member do
      get :following, :followers
    end
  end
  
  # editアクションへの名前付きルート, アカウント有効化
  resources :account_activations, only: [:edit]
  
  # パスワード再設定用リソース
  resources :password_resets,     only: [:new, :create, :edit, :update]
  
  
  resources :microposts,          only: [:create, :destroy]

  resources :relationships,       only: [:create, :destroy]

end