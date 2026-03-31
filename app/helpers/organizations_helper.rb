module OrganizationsHelper
  def format_hour(hour)
    Time.zone.parse("#{hour}:00").strftime("%-I:%M %p")
  end
end
