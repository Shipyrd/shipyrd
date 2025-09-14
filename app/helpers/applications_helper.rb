module ApplicationsHelper
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

  def display_commit_message(commit_message, application)
    return nil if commit_message.blank?
    return commit_message if application.repository_url.blank? || application.repository_url !~ /github/

    display_message = commit_message.dup
    commit_message.scan(/#(\d+)/).flatten.each do |issue_number|
      display_message.gsub!(
        "##{issue_number}",
        "<a href='#{application.repository_url}/issues/#{issue_number}'>##{issue_number}</a>"
      )
    end

    display_message
  end
end
