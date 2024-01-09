def auth_headers(password)
  {
    Authorization: ActionController::HttpAuthentication::Basic.encode_credentials(nil, password)
  }
end
