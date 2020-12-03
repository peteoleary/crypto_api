Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  #
  resources :users
  # resources :subscriptions

  get 'subscriptions', to: 'subscriptions#index'
  get 'subscriptions/validpairs', to: 'subscriptions#validpairs'
  get 'subscriptions/limits', to: 'subscriptions#limits'
  post 'subscriptions', to: 'subscriptions#create'

  post 'signup', to: 'users#create'
  post 'login', to: 'users#login'
  get 'refresh', to: 'users#refresh'
end
