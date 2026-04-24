module ChannelsHelper
  def connect_channel_url(provider, application_id:)
    case provider
    when :webhook
      new_application_webhook_url(application_id)
    when :github
      application_github_url(application_id)
    else
      oauth_authorize_url(provider, application_id: application_id)
    end
  end

  def channel_icon(channel_type)
    case channel_type.intern
    when :webhook
      "fa-solid fa-share-nodes"
    else
      "fa-brands fa-#{channel_type}"
    end
  end

  def label_for_channel_event_type(owner_type, event_type)
    case [owner_type, event_type]
    when ["Application", :deploy]
      "Deploys - Send a notification when a deploy completes"
    when ["Application", :lock]
      "Lock - Send a notification when a destination is locked"
    when ["Application", :unlock]
      "Unlock - Send a notification when a destination is unlocked"
    end
  end
end
