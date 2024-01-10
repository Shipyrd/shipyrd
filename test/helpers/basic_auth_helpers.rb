def auth_headers(password)
  {
    Authorization: ActionController::HttpAuthentication::Basic.encode_credentials(nil, password)
  }
end

def basic_auth_url(url, token)
  url = URI(url)
  url.userinfo = ":#{token}"

  url.to_s
end
