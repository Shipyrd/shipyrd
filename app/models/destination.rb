class Destination < ApplicationRecord
  belongs_to :application, optional: true, touch: true
  has_many :deploys, through: :application
  has_many :servers, dependent: :destroy

  encrypts :private_key

  before_create :generate_key_pair

  private

  def generate_key_pair
    key = SSHKey.generate(
      comment: "Shipyrd(destination=#{name})",
      type: "ECDSA",
      bits: 521
    )

    self.private_key = key.private_key
    self.public_key = key.ssh_public_key
  end
end
