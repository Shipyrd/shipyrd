def sign_in(email, password)
  visit new_session_url
  fill_in "Email", with: email
  fill_in "Password", with: password
  click_on "Sign in"
end
