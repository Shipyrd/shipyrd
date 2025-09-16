class FaviconFetchJob < ApplicationJob
  queue_as :default
  
  def perform(destination_id)
    destination = Destination.find_by(id: destination_id)
    return unless destination&.url&.present?
    
    favicon_url = destination.send(:fetch_favicon)
    destination.update_column(:favicon_url, favicon_url) if favicon_url
  end
end