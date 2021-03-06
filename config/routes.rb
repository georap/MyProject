Rails.application.routes.draw do

  resources :vehicles
  devise_for :users, path: '', path_names: {sign_in:'login', sign_out: 'logout', sign_up: 'register'}
  get 'pages/home'

  get 'pages/UserProfile'

  get 'pages/about'

  get 'pages/contact'
  get 'pages/statistics'

  resources :stations do
  	resources :reviews
  end

  mount ActionCable.server => '/cable'
  root to: 'pages#home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
