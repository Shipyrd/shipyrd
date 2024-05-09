module ApplicationHelper
  def application_status_color(status)
    case status
    when "pre-connect"
      "grey"
    when "pre-build"
      "orange"
    when "pre-deploy"
      "yellow"
    when "post-deploy"
      "green"
    end
  end
end
