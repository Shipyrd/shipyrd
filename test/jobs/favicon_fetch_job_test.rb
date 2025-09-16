require "test_helper"

class FaviconFetchJobTest < ActiveJob::TestCase
  test "fetches favicon for valid destination" do
    application = create(:application)
    destination = create(:destination, application: application, url: "https://example.com")
    
    # Mock the favicon fetching
    destination.expects(:fetch_favicon).returns("https://example.com/favicon.ico")
    Destination.expects(:find_by).with(id: destination.id).returns(destination)
    destination.expects(:update_column).with(:favicon_url, "https://example.com/favicon.ico")
    
    FaviconFetchJob.perform_now(destination.id)
  end

  test "handles missing destination gracefully" do
    # Should not raise error for non-existent destination
    FaviconFetchJob.perform_now(999999)
  end

  test "handles destination without URL gracefully" do
    application = create(:application)
    destination = create(:destination, application: application, url: nil)
    
    # Should not attempt to fetch favicon
    destination.expects(:fetch_favicon).never
    
    FaviconFetchJob.perform_now(destination.id)
  end

  test "handles favicon fetch returning nil gracefully" do
    application = create(:application)
    destination = create(:destination, application: application, url: "https://example.com")
    
    # Mock favicon fetch returning nil (no favicon found)
    destination.expects(:fetch_favicon).returns(nil)
    Destination.expects(:find_by).with(id: destination.id).returns(destination)
    destination.expects(:update_column).never
    
    FaviconFetchJob.perform_now(destination.id)
  end
end