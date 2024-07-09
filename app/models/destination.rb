class Destination < ApplicationRecord
  belongs_to :application, optional: true, touch: true
  has_many :deploys, through: :application
  has_many :servers, dependent: :destroy

  encrypts :private_key

  before_save :generate_key_pair

  def new_servers_available?
    servers.where(last_connected_at: nil).any?
  end

  private

  def generate_key_pair
    return unless private_key.blank? || public_key.blank?

    key = SSHKey.generate(
      comment: "Shipyrd(destination=#{name})",
      type: "ECDSA",
      bits: 521
    )

    self.private_key = key.private_key
    self.public_key = key.ssh_public_key
  end
end
