module DestinationsHelper
  def destination_tag(destination)
    # Adjust v-alignment on destination show/edit
    style = %w[destinations].include?(params[:controller]) ? "position: relative; top: -0.5rem;" : nil
    label_type = destination.production? ? "is-danger" : "is-info"
    klass = "tag has-text-weight-medium has-text-black my-auto is-medium is-light #{label_type}"

    content_tag(:span, style: style, class: klass) do
      link_to_if params[:action] != "edit", destination.display_name || "default", application_destination_path(destination.application, destination)
    end
  end

  def destination_deployed_badge(destination, format = :markdown)
    parameters = {
      url: destination_badge_url(destination),
      query: "deploy.time_ago",
      label: "🚀 #{destination.name}",
      color: destination.name == "production" ? "red" : nil
    }

    badge_url = "https://img.shields.io/badge/dynamic/json?" + parameters.to_query

    if format == :markdown
      "![#{destination.name}](#{badge_url})"
    else
      badge_url
    end
  end

  def destination_locked_badge(destination, format = :markdown)
    parameters = {
      url: destination_badge_url(destination),
      query: "lock.by",
      color: destination.locked? ? "yellow" : "green",
      # TODO: This can't be dynamic
      label: "#{destination.locked? ? "🔒" : "🔓"} #{destination.name}"
    }

    badge_url = "https://img.shields.io/badge/dynamic/json?" + parameters.to_query

    if format == :markdown
      "![#{destination.name}](#{badge_url})"
    else
      badge_url
    end
  end

  private

  def destination_badge_url(destination)
    badge_application_destination_url(
      destination.application.badge_key,
      destination.name || "default",
      host: "badge.shipyrd.io",
      format: :json
    )
  end
end
