SwissPairings::Application.routes.draw do
  devise_for :users

  resources :tournaments

  root to: 'welcome#index'
end
