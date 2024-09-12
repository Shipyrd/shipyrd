Rails.application.routes.draw do
  get "up" => "rails/health#show", :as => :rails_health_check

  mount MissionControl::Jobs::Engine, at: "/jobs"

  resources :deploys
  resources :applications do
    resources :connections
    resources :destinations
  end

  root "applications#index"
end
