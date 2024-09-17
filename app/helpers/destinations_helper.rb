module DestinationsHelper
  def destination_tag(destination)
    # Adjust v-alignment on destination show/edit
    style = %w[runners destinations].include?(params[:controller]) ? "position: relative; top: -0.5rem;" : nil
    label_type = destination.production? ? "is-danger" : "is-info"
    klass = "tag has-text-weight-medium has-text-black my-auto is-medium is-light #{label_type}"

    content_tag(:span, style: style, class: klass) do
      link_to_if params[:action] != "edit", destination.display_name || "default", application_destination_path(destination.application, destination)
    end
  end
end
