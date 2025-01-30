Rails.application.routes.draw do
  devise_for :users
  root "todo_lists#index"

  resources :todo_lists, path: :todolists do
    resources :items, path: :todos, only: [:create, :update, :destroy]
  end

  namespace :api do
    resources :todo_lists, path: :todolists, except: [:new, :edit] do
      resources :items, path: :todos, except: [:new, :edit]
    end
  end
end
