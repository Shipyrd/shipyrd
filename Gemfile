source "https://rubygems.org"

ruby file: ".ruby-version"

gem "rails", "~> 7.1.2"
gem "dotenv-rails"
gem "puma", ">= 5.0"
gem "propshaft"
gem "importmap-rails"
gem "turbo-rails", github: "hotwired/turbo-rails" # for broadcasts_refreshes support
gem "stimulus-rails"
gem "jbuilder"
gem "bootsnap", require: false
gem "solid_cable"
gem "sqlite3", "~> 1.7.3"
gem "appsignal", require: false # TODO: Verify loading properly
gem "sshkey"

group :development, :test do
  gem "brakeman"
  gem "factory_bot_rails"
  gem "faker"
  gem "debug", platforms: %i[mri windows]
  gem "pry"
  gem "standard"
  gem "standard-rails"
end

group :development do
  gem "web-console"
  gem "guard"
  gem "guard-minitest"
  gem "guard-standardrb"
end

group :test do
  gem "minitest-spec-rails"
  gem "capybara"
  gem "launchy"
  gem "mocha"
  gem "selenium-webdriver"
  gem "webdrivers"
  gem "webmock"
end
