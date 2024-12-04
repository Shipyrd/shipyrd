Rails.application.routes.draw do
  get "up" => "rails/health#show", :as => :rails_health_check

  mount MissionControl::Jobs::Engine, at: "/jobs"

  resources :users
  resource :session
  resources :invite_links
  resources :deploys

  resources :applications do
    resources :connections
    resources :destinations do
      member do
        patch 'lock'
        patch 'unlock'
      end
      resources :runners
    end
  end

  root "applications#index"
end
