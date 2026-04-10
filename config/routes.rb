Rails.application.routes.draw do
  get "up", to: ->(env) {
    ActiveRecord::Migrator.current_version

    [200, {}, [""]]
  }

  mount MissionControl::Jobs::Engine, at: "/jobs"

  constraints(SystemAdminConstraint.new) do
    mount Blazer::Engine, at: "/blazer"
  end

  namespace :incoming do
    post "honeybadger/:token", action: :create, controller: :honeybadger, as: :honeybadger
    post "stripe", action: :create, controller: :stripe, as: :stripe
  end

  resources :users
  resources :organizations, only: %i[new create edit update] do
    member do
      post :switch
    end
  end
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
    member do
      get :setup
    end
    resources :channels, only: %i[edit update destroy]
    resources :webhooks, only: %i[new create]
    resources :incoming_webhooks, only: %i[new create destroy]
    resources :destinations do
      member do
        patch "lock"
        put "lock"
        delete "unlock"
        get "badge/deploy", action: :deploy, controller: "badge", as: :badge_deploy
        get "badge/lock", action: :lock, controller: "badge", as: :badge_lock
        get "deploys", action: :deploys, as: :deploys
      end
    end
  end

  root "applications#index"
end
