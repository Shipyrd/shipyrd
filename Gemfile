source "https://rubygems.org"

ruby "3.2.2"

gem "rails", github: "rails/rails", branch: "main"
gem "sprockets-rails"
gem "mysql2"
gem "dotenv-rails"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "jbuilder"
gem "bootsnap", require: false
gem "redis"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
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
end
