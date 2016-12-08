Rails.application.routes.draw do
  get 'teams/index'

  get 'users/index'

  get 'sessions/new'

  get 'users/new'

  root   'static_pages#home'
  get    '/help',                           to: 'static_pages#help'
  get    '/about',                          to: 'static_pages#about'
  get    '/contact',                        to: 'static_pages#contact'
  get    '/signup',                         to: 'users#new'
  get    '/login',                          to: 'sessions#new'
  get    '/rankings',                       to: 'teams#index'
  get    '/predictions/:year/:month/:day',  to: 'games#predictions'
  post   '/login',                          to: 'sessions#create'
  delete '/logout',                         to: 'sessions#destroy'
  resources :users
  resources :teams, only: [:show], constraints: { id: /[^\/]+/ }
  resources :games, only: [:show]
end
