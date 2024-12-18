class Slack
  attr_accessor :token

  def initialize(token)
    @token = token
  end

  def notify(event, details)
    raise ArgumentError, "Invalid event" unless %i[lock unlock].include?(event.intern)

    emoji = (event == :lock) ? ":lock:" : ":unlock:"
    message = "#{emoji} #{details[:user_name]} #{event}ed #{details[:application_name]}"
    message += "(#{details[:destination_name]})" if details[:destination_name].present?

    send_message(
      channel_id: details[:channel_id],
      message: message
    )
  end

  private

  def send_message(channel_id:, message:)
    Faraday.new do |faraday|
      faraday.request :json
      faraday.response :logger, Rails.logger if Rails.env.development?
    end.post("https://slack.com/api/chat.postMessage") do |req|
      req.headers["Content-Type"] = "application/json"
      req.headers["Authorization"] = "Bearer #{token}"
      req.body = {channel: channel_id, text: message}.to_json
    end
  end
end
