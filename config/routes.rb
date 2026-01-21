Rails.application.routes.draw do
  get "up", to: ->(env) {
    ActiveRecord::Migrator.current_version

    [200, {}, [""]]
  }

  mount MissionControl::Jobs::Engine, at: "/jobs"

  namespace :incoming do
    post "honeybadger/:token", action: :create, controller: :honeybadger, as: :honeybadger
  end

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
    resources :incoming_webhooks, only: %i[new create destroy]
    resources :destinations do
      member do
        patch "lock"
        delete "unlock"
      end
    end
  end

  root "applications#index"
end
