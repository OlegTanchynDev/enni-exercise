Rails.application.routes.draw do
  devise_for :users
  use_doorkeeper

  root "home#index"

  # Operator portal (web UI). The Facility Verification Card (TASK 2) lives at
  # /portal/facilities/:id.
  namespace :portal do
    get "/", to: "dashboard#index", as: :dashboard
    resources :facilities, only: [:show]
    resources :booking_instances, only: [] do
      resources :cleaning_photos, only: [:create]
    end
  end

  # Doorkeeper-protected JSON API. The verification feed (TASK 1b) lives here.
  namespace :api do
    namespace :v1 do
      resources :booking_instances, only: [:index]
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
