module IncomingWebhooksHelper
  def incoming_webhook_icon(provider)
    image_tag("incoming_webhooks/logos/#{provider}.svg", size: "20x20", alt: provider.to_s.titleize)
  end
end
