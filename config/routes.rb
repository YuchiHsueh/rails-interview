Rails.application.routes.draw do
  namespace :api do
    resources :todo_lists, path: :todolists do
      resources :items, path: :todos
    end
  end

  resources :todo_lists, path: :todolists do
    resources :items, only: %i[ create destroy update ], path: :todos
  end
end
