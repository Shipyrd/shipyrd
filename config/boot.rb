ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

ENV["SECRET_KEY_BASE"] = ENV["SHIPYRD_SECRET_KEY_BASE"]

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.
