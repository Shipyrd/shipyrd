ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

ENV["SECRET_KEY_BASE"] = ENV["SHIPYRD_SECRET_KEY_BASE"]
ENV["ENCRYPTION_DETERMINISTIC_KEY"] = ENV["SHIPYRD_ENCRYPTION_DETERMINISTIC_KEY"]
ENV["ENCRYPTION_PRIMARY_KEY"] = ENV["SHIPYRD_ENCRYPTION_PRIMARY_KEY"]
ENV["ENCRYPTION_KEY_DERIVATION_SALT"] = ENV["SHIPYRD_ENCRYPTION_KEY_DERIVATION_SALT"]

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.
