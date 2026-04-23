module ApplicationsHelper
  def application_status_color(status)
    case status
    when "pre-connect" then "grey"
    when "pre-build" then "orange"
    when "pre-deploy" then "yellow"
    when "post-deploy" then "green"
    when "failed" then "red"
    end
  end

  def display_commit_message(commit_message, application)
    return nil if commit_message.blank?
    return commit_message if application.repository_url.blank?
    return commit_message unless application.repository_url.match?(%r{\Ahttps://(github|gitlab)\.com/})

    display_message = commit_message.dup
    commit_message.scan(/#(\d+)/).flatten.each do |issue_number|
      issue_url = "#{application.repository_url}/issues/#{ERB::Util.url_encode(issue_number)}"
      display_message.gsub!(
        "##{issue_number}",
        "<a href='#{ERB::Util.html_escape(issue_url)}'>##{issue_number}</a>"
      )
    end

    display_message
  end
end
