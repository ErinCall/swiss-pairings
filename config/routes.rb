SwissPairings::Application.routes.draw do
  devise_for :users

  resources :tournaments do
    resources :players, :matches

    post :start, on: :member
  end

  root to: 'welcome#index'
end
