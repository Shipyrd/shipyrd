class Server < ApplicationRecord
  belongs_to :destination, counter_cache: true

  broadcasts
end
