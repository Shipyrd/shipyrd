class ApiKey < ApplicationRecord
  has_secure_token, length: 64
end
