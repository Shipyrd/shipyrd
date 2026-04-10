if ENV["BREVO_API_KEY"].present?
  Brevo.configure do |config|
    config.api_key["api-key"] = ENV["BREVO_API_KEY"]
  end
end
