require "ipaddr"
require "resolv"
require "uri"

module UrlSafety
  class BlockedHostError < StandardError; end

  def self.verify!(url)
    uri = URI.parse(url.to_s)
    raise BlockedHostError, "https is required" unless uri.scheme == "https"
    raise BlockedHostError, "host required" if uri.host.blank?

    addresses = Resolv.getaddresses(uri.host)
    raise BlockedHostError, "no DNS results for #{uri.host}" if addresses.empty?

    addresses.each do |address|
      ip = IPAddr.new(address)
      next unless blocked?(ip)
      raise BlockedHostError, "blocked address: #{address}"
    end

    [uri, addresses.first]
  end

  def self.blocked?(ip)
    ip.loopback? || ip.private? || ip.link_local? ||
      ip == IPAddr.new("0.0.0.0") || ip == IPAddr.new("::")
  end
end
