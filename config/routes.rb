Rails.application.routes.draw do
  get "up" => "rails/health#show", :as => :rails_health_check

  mount MissionControl::Jobs::Engine, at: "/jobs"

  resources :users
  resource :session
  resources :invite_links
  resources :deploys

  namespace :oauth do
    get "authorize/:provider", action: :authorize, as: :authorize
    get "callback/:provider", action: :callback, as: :callback
    delete "destroy/:id", action: :destroy, as: :destroy
  end

  resources :applications do
    resources :connections
    resources :channels
    resources :destinations do
      member do
        patch "lock"
        patch "unlock"
      end
      resources :runners
    end
  end

  root "applications#index"
end
