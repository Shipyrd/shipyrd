Rails.application.routes.draw do
  get "up" => "rails/health#show", :as => :rails_health_check

  mount MissionControl::Jobs::Engine, at: "/jobs"

  resources :users
  resources :organizations, only: %i[edit update]
  resource :session
  resources :invite_links
  resources :deploys

  namespace :oauth do
    get "authorize/:provider", action: :authorize, as: :authorize
    get "callback/:provider", action: :callback, as: :callback
  end

  resources :applications do
    resources :channels, only: %i[edit update destroy]
    resources :webhooks, only: %i[new create]
    resources :destinations do
      member do
        patch "lock"
        patch "unlock"
      end
    end
  end

  root "applications#index"
end
