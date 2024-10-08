source "https://rubygems.org"

ruby file: ".ruby-version"

# Core
gem "bootsnap", require: false
gem "dotenv-rails"
gem "kamal"
gem "puma", ">= 5.0"
gem "rails", "~> 7.2.1"
gem "sqlite3", "~> 2.1.0"

# Assets
gem "propshaft"
gem "importmap-rails"
gem "turbo-rails", "= 2.0.7"
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
  gem "bullet"
  gem "bundle-audit"
  gem "debug", platforms: %i[mri windows]
  gem "factory_bot_rails"
  gem "faker"
  gem "pry"
  gem "standard"
  gem "standard-rails"
end

group :development do
  gem "guard"
  gem "guard-minitest"
  gem "guard-standardrb"
  gem "hotwire-livereload"
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "launchy"
  gem "minitest-spec-rails"
  gem "mocha"
  gem "selenium-webdriver"
  gem "webdrivers"
  gem "webmock"
end
