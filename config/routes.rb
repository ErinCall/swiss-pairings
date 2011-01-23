SwissPairings::Application.routes.draw do
  devise_for :users

  resources :tournaments do
    resources :players
  end

  root to: 'welcome#index'
end
