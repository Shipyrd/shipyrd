Rails.application.routes.draw do
  get "up", to: ->(env) {
    ActiveRecord::Migrator.current_version

    [200, {}, [""]]
  }

  mount MissionControl::Jobs::Engine, at: "/jobs"

  namespace :incoming do
    post "honeybadger/:token", action: :create, controller: :honeybadger, as: :honeybadger
    post "stripe", action: :create, controller: :stripe, as: :stripe
  end

  resources :users
  resources :organizations, only: %i[edit update]
  resource :session
  resources :invite_links
  resources :deploys
  get "billing/setup", to: "billing#setup", as: :billing_setup
  get "billing/checkout", to: "billing#checkout", as: :billing_checkout

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
