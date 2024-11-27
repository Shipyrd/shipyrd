def sign_in_as(email, password)
  visit new_session_url

  fill_in "Email", with: email
  fill_in "Password", with: password

  click_button "Sign in"
  sleep(1)
end
