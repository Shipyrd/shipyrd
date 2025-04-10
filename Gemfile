source "https://rubygems.org"

ruby file: ".ruby-version"

# Core
gem "bcrypt", "~> 3.1.7"
gem "bootsnap", require: false
gem "dotenv"
gem "kamal"
gem "puma", ">= 5.0"
gem "mysql2", "~> 0.5.6"
gem "rails", "~> 8.0.2"
gem "rails_semantic_logger", require: false

# Assets
gem "propshaft"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"

# 3rd Party
gem "faraday" # Already required by oauth2 and github_api but using it directly
gem "github_api"
gem "honeybadger"
gem "oauth2"

# Jobs/Cable
gem "mission_control-jobs"
gem "solid_cable"
gem "solid_queue"

# Misc.
gem "jbuilder"
gem "sshkey"
gem "tty-command"
gem "validate_url"

group :development, :test do
  gem "brakeman"
  gem "bullet"
  gem "bundle-audit"
  gem "debug", platforms: %i[mri windows]
  gem "factory_bot_rails"
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
  gem "selenium-webdriver"
  gem "webdrivers"
  gem "launchy"
  gem "minitest-spec-rails"
  gem "mocha"
  gem "webmock"
end
