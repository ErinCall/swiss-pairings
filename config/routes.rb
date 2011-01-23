SwissPairings::Application.routes.draw do
  devise_for :users

  resources :tournaments do
    resources :players

    post :start, on: :member
  end

  root to: 'welcome#index'
end
