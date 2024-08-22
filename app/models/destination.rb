class Destination < ApplicationRecord
  belongs_to :application, optional: true, touch: true
  has_many :deploys, through: :application
  has_many :servers, dependent: :destroy

  encrypts :private_key

  before_save :generate_key_pair
  after_update_commit :process_recipe, if: -> { saved_change_to_recipe? }

  def new_servers_available?
    servers.where(last_connected_at: nil).any?
  end

  def recipe_path
    "config/#{recipe_name}"
  end

  def recipe_name
    "deploy#{name.present? ? ".#{name}" : nil}.yml"
  end

  def display_name
    name.presence || "default"
  end

  def default?
    name.blank?
  end

  def with_recipe
    tmp_dir = Rails.root.join("tmp", "#{SecureRandom.hex(10)}/config")
    FileUtils.mkdir_p(tmp_dir)

    # config/deploy.yml
    base_recipe_path = "#{tmp_dir}/deploy.yml"
    File.write(base_recipe_path, base_recipe)

    unless default?
      # config/deploy.production.yml
      File.write("#{tmp_dir}/#{recipe_name}", recipe)
    end

    yield(base_recipe_path)

    FileUtils.remove_dir(tmp_dir) if File.directory?(tmp_dir)
  end

  private

  def process_recipe
    with_recipe do |base_recipe_path|
      kamal_config = Kamal::Configuration.create_from(
        config_file: Pathname.new(File.expand_path(base_recipe_path)),
        destination: name
      )

      kamal_config.roles.each do |role|
        role.hosts.each do |host|
          servers.find_or_create_by!(host: host)
        end
      end
    end
  end

  def generate_key_pair
    return unless private_key.blank? || public_key.blank?

    key = SSHKey.generate(
      comment: "Shipyrd - #{application.name}@#{name}",
      type: "ECDSA",
      bits: 521
    )

    self.private_key = key.private_key
    self.public_key = key.ssh_public_key
  end
end
