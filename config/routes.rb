Rails.application.routes.draw do
  get "up" => "rails/health#show", :as => :rails_health_check

  resources :api_keys
  resources :deploys
  resources :applications

  root "applications#index"
end
