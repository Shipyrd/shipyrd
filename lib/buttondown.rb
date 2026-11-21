class Buttondown
  SUBSCRIBERS_URL = "https://api.buttondown.com/v1/subscribers"
  API_VERSION = "2026-04-01"

  attr_accessor :token

  def initialize(token)
    @token = token
  end

  # Adds an email address to the newsletter.
  #
  # `type: "regular"` opts the subscriber in directly. Buttondown defaults to
  # double opt-in, which would leave them `unactivated` until they confirmed.
  #
  # The collision-behavior header makes a repeat subscribe merge into the
  # existing subscriber instead of returning a 400.
  def subscribe(email)
    raise ArgumentError, "Invalid email" if email.blank?

    Faraday.new(request: {timeout: 10, open_timeout: 5}) do |faraday|
      faraday.request :json
      faraday.response :raise_error
      faraday.response :logger, Rails.logger if Rails.env.development?
    end.post(SUBSCRIBERS_URL) do |req|
      req.headers["Content-Type"] = "application/json"
      req.headers["Authorization"] = "Token #{token}"
      req.headers["X-API-Version"] = API_VERSION
      req.headers["X-Buttondown-Collision-Behavior"] = "add"
      req.body = {
        email_address: email,
        type: "regular"
      }.to_json
    end
  end
end
