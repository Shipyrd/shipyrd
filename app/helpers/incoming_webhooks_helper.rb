module IncomingWebhooksHelper
  def incoming_webhook_icon(provider)
    case provider.intern
    when :honeybadger
      "fa-solid fa-otter" # Yes, it's not a honeybadger
    end
  end
end
