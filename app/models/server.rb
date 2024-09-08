class Server < ApplicationRecord
  belongs_to :destination

  broadcasts
end
