class GithubAppClient
  def self.installation_token(installation_id)
    Octokit::Client.new(bearer_token: generate_jwt).create_app_installation_access_token(installation_id).token
  end

  def self.installation_repositories(installation_id)
    token = installation_token(installation_id)
    response = Octokit::Client.new(access_token: token).get("/installation/repositories", per_page: 100)
    response.repositories.map { |r| {full_name: r.full_name, html_url: r.html_url} }
  rescue => e
    Rails.logger.error "GithubAppClient.installation_repositories failed: #{e.class}: #{e.message}"
    nil
  end

  private_class_method def self.generate_jwt
    private_key = OpenSSL::PKey::RSA.new(ENV["SHIPYRD_GITHUB_APP_PRIVATE_KEY"])
    payload = {
      iat: Time.now.to_i - 60,
      exp: Time.now.to_i + (10 * 60),
      iss: ENV["SHIPYRD_GITHUB_APP_ID"].to_i
    }
    JWT.encode(payload, private_key, "RS256")
  end
end
