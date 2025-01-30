Rails.application.routes.draw do
  devise_for :users
  root "todo_lists#index"

  resources :todo_lists, path: :todolists do
    resources :items, path: :todos, only: [:create, :update, :destroy]
  end

  namespace :api do
    resources :todo_lists, path: :todolists, only: [] do
      resources :items, path: :todos, only: [:update]
    end
  end
end
