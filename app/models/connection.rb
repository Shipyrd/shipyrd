class Connection < ApplicationRecord
  belongs_to :application

  encrypts :key

  PROVIDERS = %w[github].freeze

  # TODO: Verify connection with provider API and store in last_connected_at
end
