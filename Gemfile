source "https://rubygems.org"

ruby "3.2.2"

gem "rails", "~> 7.1.2"
gem "sprockets-rails"
gem "dotenv-rails"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "jbuilder"
gem "bootsnap", require: false
gem "redis"
gem "heroicon"
gem "litestack"

group :development, :test do
  gem "factory_bot_rails"
  gem "faker"
  gem "debug", platforms: %i[mri windows]
  gem "standard"
end

group :development do
  gem "hotwire-livereload", "~> 1.2"
  gem "web-console"
  gem "guard"
  gem "guard-minitest"
  gem "guard-standardrb"
  gem "error_highlight", ">= 0.4.0", platforms: [:ruby]
end

group :test do
  gem "minitest-spec-rails"
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
  gem "webmock"
end
