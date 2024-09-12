source "https://rubygems.org"

ruby file: ".ruby-version"

# Core
gem "bootsnap", require: false
gem "dotenv-rails"
gem "kamal"
gem "puma", ">= 5.0"
gem "rails", "~> 7.1.3.4"
gem "sqlite3", "~> 1.7.3"

# Assets
gem "propshaft"
gem "importmap-rails"
gem "turbo-rails", github: "hotwired/turbo-rails" # for broadcasts_refreshes support
gem "stimulus-rails"

# 3rd Party
gem "github_api"
gem "honeybadger", require: false

# Jobs/Cable
gem "mission_control-jobs"
gem "solid_cable"
gem "solid_queue"

# Misc.
gem "jbuilder"
gem "sshkey"
gem "tty-command"

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
