class Slack
  class StatusBlocks
    include Rails.application.routes.url_helpers

    def self.build(destinations)
      new(destinations).build
    end

    def initialize(destinations)
      @destinations = destinations
    end

    def build
      [{type: "table", rows: [header_row] + data_rows}]
    end

    private

    attr_reader :destinations

    def header_row
      ["App", "Destination", "Lock", "Last deploy"].map do |h|
        {type: "raw_text", text: h}
      end
    end

    def data_rows
      destinations.map do |d|
        [
          app_name_cell(d.application),
          {type: "raw_text", text: d.display_name},
          lock_cell(d),
          deploy_cell(d)
        ]
      end
    end

    def lock_cell(destination)
      emoji, text = destination.locked? ?
        ["red_circle", " locked by #{destination.locked_by}"] :
        ["large_green_circle", " unlocked"]

      rich_text_section_cell([
        {type: "emoji", name: emoji},
        {type: "text", text: text}
      ])
    end

    def deploy_cell(destination)
      deploy = destination.latest_deploy
      return {type: "raw_text", text: "no deploys"} unless deploy

      sha = deploy.version
      short_sha = sha&.first(7) || "unknown"
      repo_url = destination.application.repository_url
      suffix = " (#{deploy.status})"

      if sha.present? && repo_url.present?
        rich_text_section_cell([
          {type: "link", url: "#{repo_url}/commit/#{sha}", text: short_sha},
          {type: "text", text: suffix}
        ])
      else
        {type: "raw_text", text: "#{short_sha}#{suffix}"}
      end
    end

    def app_name_cell(application)
      rich_text_section_cell([
        {
          type: "link",
          url: application_url(application, host: ENV["SHIPYRD_HOST"], protocol: "https"),
          text: application.name
        },
        {type: "text", text: " (`#{application.slug}`)"}
      ])
    end

    def rich_text_section_cell(elements)
      {
        type: "rich_text",
        elements: [{type: "rich_text_section", elements: elements}]
      }
    end
  end
end
