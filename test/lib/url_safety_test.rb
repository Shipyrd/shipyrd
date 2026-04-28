require "test_helper"

class UrlSafetyTest < ActiveSupport::TestCase
  test "permits public https hosts" do
    Resolv.stubs(:getaddresses).returns(["93.184.216.34"])
    assert UrlSafety.verify!("https://example.com/hooks")
  end

  test "rejects http scheme" do
    assert_raises(UrlSafety::BlockedHostError) do
      UrlSafety.verify!("http://example.com/")
    end
  end

  test "rejects loopback addresses" do
    Resolv.stubs(:getaddresses).returns(["127.0.0.1"])
    assert_raises(UrlSafety::BlockedHostError) do
      UrlSafety.verify!("https://example.com/")
    end
  end

  test "rejects RFC1918 private addresses" do
    %w[10.0.0.1 172.16.0.1 192.168.1.1].each do |addr|
      Resolv.stubs(:getaddresses).returns([addr])
      assert_raises(UrlSafety::BlockedHostError, "expected #{addr} to be blocked") do
        UrlSafety.verify!("https://example.com/")
      end
    end
  end

  test "rejects link-local (cloud metadata) addresses" do
    Resolv.stubs(:getaddresses).returns(["169.254.169.254"])
    assert_raises(UrlSafety::BlockedHostError) do
      UrlSafety.verify!("https://example.com/")
    end
  end

  test "rejects IPv6 loopback and link-local" do
    %w[::1 fe80::1].each do |addr|
      Resolv.stubs(:getaddresses).returns([addr])
      assert_raises(UrlSafety::BlockedHostError, "expected #{addr} to be blocked") do
        UrlSafety.verify!("https://example.com/")
      end
    end
  end

  test "rejects unsupported schemes" do
    assert_raises(UrlSafety::BlockedHostError) do
      UrlSafety.verify!("file:///etc/passwd")
    end
    assert_raises(UrlSafety::BlockedHostError) do
      UrlSafety.verify!("gopher://example.com/")
    end
  end

  test "rejects when DNS returns no addresses" do
    Resolv.stubs(:getaddresses).returns([])
    assert_raises(UrlSafety::BlockedHostError) do
      UrlSafety.verify!("https://nope.invalid/")
    end
  end

  test "rejects when any resolved address is private" do
    Resolv.stubs(:getaddresses).returns(["93.184.216.34", "10.0.0.1"])
    assert_raises(UrlSafety::BlockedHostError) do
      UrlSafety.verify!("https://example.com/")
    end
  end
end
