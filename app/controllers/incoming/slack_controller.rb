class Incoming::SlackController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :authenticate

  before_action :verify_slack_signature
  before_action :find_organization

  def create
    command, app_name, destination_name = params[:text].to_s.strip.split(/\s+/, 3)

    case command
    when "lock"
      actor = find_actor
      return unless actor

      destination = find_destination(app_name, destination_name)
      return unless destination

      if destination.locked?
        slack_respond(":red_circle: *#{destination.application.name}* (#{destination.display_name}) is already locked by #{destination.locked_by}.")
      else
        destination.lock!(actor)
        slack_respond(":red_circle: <@#{params[:user_id]}> locked *#{destination.application.name}* (#{destination.display_name}).", in_channel: true)
      end

    when "unlock"
      actor = find_actor
      return unless actor

      destination = find_destination(app_name, destination_name)
      return unless destination

      if destination.unlocked?
        slack_respond(":large_green_circle: *#{destination.application.name}* (#{destination.display_name}) is not currently locked.")
      else
        destination.unlock!(actor)
        slack_respond(":large_green_circle: <@#{params[:user_id]}> unlocked *#{destination.application.name}* (#{destination.display_name}).", in_channel: true)
      end

    when "status"
      if app_name.present?
        destination = find_destination(app_name, destination_name)
        return unless destination

        slack_respond("Status for #{destination.application.name}", blocks: Slack::StatusBlocks.build([destination]))
      else
        destinations = @organization.applications.includes(destinations: :locker).flat_map(&:destinations)
        if destinations.any?
          slack_respond("Deployment status", blocks: Slack::StatusBlocks.build(destinations))
        else
          slack_respond("No applications found.")
        end
      end

    else
      slack_respond(usage_text)
    end
  end

  private

  def verify_slack_signature
    secret = ENV["SHIPYRD_SLACK_SIGNING_SECRET"]
    raise "SHIPYRD_SLACK_SIGNING_SECRET must be configured to accept Slack slash commands" if secret.blank?

    timestamp = request.headers["X-Slack-Request-Timestamp"]
    signature = request.headers["X-Slack-Signature"]

    if timestamp.blank? || signature.blank?
      head :unauthorized and return
    end

    if (Time.now.to_i - timestamp.to_i).abs > 300
      head :unauthorized and return
    end

    expected = "v0=" + OpenSSL::HMAC.hexdigest(
      "SHA256",
      secret,
      "v0:#{timestamp}:#{request.raw_post}"
    )

    unless signature.bytesize == expected.bytesize &&
        ActiveSupport::SecurityUtils.secure_compare(expected, signature)
      head :unauthorized and return
    end
  end

  def find_organization
    @organization = Organization.find_by(slack_team_id: params[:team_id])

    unless @organization
      slack_respond("This workspace isn't connected to Shipyrd. Visit <https://#{ENV["SHIPYRD_HOST"]}|Shipyrd> to connect it.")
      false
    end
  end

  def find_actor
    membership = @organization.memberships.find_by(slack_user_id: params[:user_id])

    if membership.nil?
      email = fetch_slack_user_email(params[:user_id])

      if email.blank?
        slack_respond("Unable to verify your identity. Please try again.")
        return nil
      end

      user = @organization.users
        .left_joins(:email_addresses)
        .where("users.email = :email OR email_addresses.email = :email", email: email)
        .first

      unless user
        slack_respond("Your Slack account doesn't match any Shipyrd user in this organization.")
        return nil
      end

      membership = bind_slack_user_id(user)
    end

    membership.user
  end

  def fetch_slack_user_email(slack_user_id)
    response = Faraday.new("https://slack.com",
      headers: {"Authorization" => "Bearer #{@organization.slack_access_token}"},
      request: {open_timeout: 5, timeout: 5}) do |f|
      f.response :json
    end.get("/api/users.info", user: slack_user_id)

    return nil unless response.success? && response.body.is_a?(Hash) && response.body["ok"]

    response.body.dig("user", "profile", "email")
  rescue Faraday::Error, JSON::ParserError => e
    Rails.logger.warn("Slack users.info failed: #{e.class}: #{e.message}")
    nil
  end

  def bind_slack_user_id(user)
    membership = @organization.memberships.find_by!(user: user)
    membership.update_column(:slack_user_id, params[:user_id])
    membership
  rescue ActiveRecord::RecordNotUnique
    @organization.memberships.find_by!(slack_user_id: params[:user_id])
  end

  def find_destination(app_name, destination_name)
    if app_name.blank?
      slack_respond(usage_text)
      return nil
    end

    app = @organization.applications.find_by(slug: app_name.downcase)
    unless app
      slack_respond("App *#{app_name}* not found.")
      return nil
    end

    destinations = app.destinations.to_a
    destination = if destination_name.present?
      target = destination_name.downcase
      destinations.find { |d| d.name&.downcase == target }
    elsif destinations.size == 1
      destinations.first
    else
      destinations.find { |d| d.name.nil? }
    end

    unless destination
      if destination_name.blank? && destinations.size > 1
        names = destinations.map { |d| "`#{d.display_name}`" }.join(", ")
        slack_respond("Multiple destinations exist for *#{app_name}*. Please specify one: #{names}")
      else
        slack_respond("Destination *#{destination_name || "default"}* not found for *#{app_name}*.")
      end
      return nil
    end

    destination
  end

  def slack_respond(text, blocks: nil, in_channel: false)
    payload = {
      response_type: in_channel ? "in_channel" : "ephemeral",
      text: text
    }
    payload[:blocks] = blocks if blocks
    render json: payload
  end

  def usage_text
    <<~TEXT.strip
      Usage:
      `/shipyrd lock appname [destination]`
      `/shipyrd unlock appname [destination]`
      `/shipyrd status [appname] [destination]`
    TEXT
  end
end
