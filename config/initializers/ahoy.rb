class Ahoy::Store < Ahoy::DatabaseStore
  def track_visit(data)
    return if ENV["COMMUNITY_EDITION"] != "0"
    super
  end

  def track_event(data)
    return if ENV["COMMUNITY_EDITION"] != "0"
    super
  end
end

Ahoy.visit_duration = 30.minutes
Ahoy.server_side_visits = :when_needed

Ahoy.mask_ips = true
Ahoy.cookies = :none
Ahoy.geocode = false
