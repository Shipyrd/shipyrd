class Destination < ApplicationRecord
  belongs_to :application, optional: true, touch: true
  belongs_to :locker, class_name: "User", optional: true, foreign_key: :locked_by_user_id
  has_many :deploys, through: :application
  has_many :servers, dependent: :destroy
  has_many :runners, dependent: :destroy
  has_many :channels, through: :application

  encrypts :private_key

  before_save :generate_key_pair
  after_update_commit :process_recipe, if: -> { saved_change_to_recipe? }

  scope :latest, -> { order(created_at: :desc) }

  broadcasts

  def new_servers_available?
    servers.where(last_connected_at: nil).any?
  end

  def recipe_path
    "config/#{recipe_name}"
  end

  def recipe_name
    "deploy#{name.present? ? ".#{name}" : nil}.yml"
  end

  def dispatch_notifications(event, details)
    channels.each do |channel|
      next unless channel.events.include?(event.to_s)

      channel.notifications.create!(
        event: event,
        destination: self,
        details: details
      )
    end
  end

  def locked?
    locked_at.present?
  end

  def lock!(user)
    update!(
      locked_at: Time.current,
      locker: user
    )

    dispatch_notifications(:lock, {locked_at: Time.current, user_id: user.id})
  end

  def unlock!(user)
    update!(
      locked_at: nil,
      locker: nil
    )

    dispatch_notifications(:unlock, {user_id: user.id})
  end

  def on_deck_url
    return nil if application.repository_url.blank?
    return nil if latest_deployed_sha.blank? || latest_deployed_sha =~ /uncommitted/
    return nil if branch.blank?

    "#{application.repository_url}/compare/#{latest_deployed_sha}...#{branch}"
  end

  def latest_deployed_sha
    @latest_deployed_sha ||= deploys.where(
      destination: name,
      command: :deploy,
      status: "post-deploy"
    ).last&.version
  end

  def display_name
    name.presence || "default"
  end

  def default?
    name.blank?
  end

  def production?
    name == "production"
  end

  def with_recipe
    tmp_dir = Rails.root.join("tmp", SecureRandom.hex(10))
    config_dir = "#{tmp_dir}/config"
    FileUtils.mkdir_p(config_dir)

    # config/deploy.yml
    base_recipe_path = "#{config_dir}/deploy.yml"
    base_recipe_content = YAML.load(base_recipe)

    base_recipe_content["ssh"] = {} if base_recipe_content["ssh"].blank?
    base_recipe_content["ssh"]["keys_only"] = true
    base_recipe_content["ssh"]["key_data"] = [private_key.to_s]

    File.write(base_recipe_path, base_recipe_content.to_yaml)

    unless default?
      # config/deploy.production.yml
      File.write("#{config_dir}/#{recipe_name}", recipe)
    end

    yield(config_dir)
  ensure
    FileUtils.remove_dir(tmp_dir) if File.directory?(tmp_dir)
  end

  private

  def process_recipe
    with_recipe do |base_recipe_dir|
      config = YAML.load_file("#{base_recipe_dir}/deploy.yml").symbolize_keys

      unless default?
        config.deep_merge!(
          YAML.load_file("#{base_recipe_dir}/#{recipe_name}").symbolize_keys
        )
      end

      kamal_config = Kamal::Configuration.new(
        config,
        destination: name,
        validate: false
      )

      kamal_config.roles.each do |role|
        role.hosts.each do |host|
          servers.find_or_create_by!(host: host)
        end
      end
    end

    update!(recipe_last_processed_at: Time.current)
  rescue => e
    logger.info "Failed to process recipe #{e}"
    false
  end

  def generate_key_pair
    return unless private_key.blank? || public_key.blank?

    key = SSHKey.generate(
      comment: "Shipyrd - #{application.name} - #{name}"
    )

    self.private_key = key.private_key
    self.public_key = key.ssh_public_key
  end
end
