module ChannelsHelper
  def channel_icon(channel_type)
    case channel_type
    when "webhook"
      "fa-solid fa-bolt"
    else
      "fa-brands fa-#{channel_type}"
    end
  end

  def label_for_channel_event_type(owner_type, event_type)
    case [owner_type, event_type]
    when ["Application", :deploy]
      "Deploys - Send a notification when a deploy completes"
    when ["Application", :lock]
      "Locks - Send a notification when a destination is locked/unlocked"
    end
  end
end
