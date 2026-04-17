Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # --- Authentication ---
  post "auth/register", to: "auth#register"
  post "auth/login",    to: "auth#login"

  # --- Users ---
  get  "users/me/stats", to: "users#stats"
  get  "users/me",  to: "users#me"
  patch "users/me", to: "users#update"
  delete "users/me", to: "users#destroy"
  resources :users, only: [ :index, :show ]

  # --- Products (public browse, authenticated CUD) ---
  resources :products do
    collection do
      get :explore
    end
  end

  # --- Orders (scoped to current_user) ---
  resources :orders do
    # Nested: order items
    resources :order_items

    # Nested: payments
    resources :payments
  end
end
