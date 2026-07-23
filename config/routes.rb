Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Mount Action Cable server
  mount ActionCable.server => "/cable"

  # Defines the root path route ("../")
  root "dashboard#index"

  get "explorer", to: "explorer#index"
  get "live_stream", to: "live_stream#index"

  # API reference docs
  get "doc", to: "doc#show"

  # Alerts
  resources :alerts, only: [ :index ] do
    member do
      post :acknowledge
      post :resolve
    end
  end

  resources :alert_rules do
    member do
      post :toggle
    end
  end

  # Service management
  get "services", to: "services#index"
  post "services", to: "services#create"
  post "services/regenerate_token/:id", to: "services#regenerate_token", as: :regenerate_token_service

  # User profile
  resource :profile, only: [ :show, :update ]

  # API
  namespace :api do
    namespace :v1 do
      resources :logs, only: [ :index, :show, :create ]
      resources :server_checks, only: [ :index, :create ]
    end
  end
end
