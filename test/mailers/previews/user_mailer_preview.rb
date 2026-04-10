class UserMailerPreview < ActionMailer::Preview
  def email_verification
    user = User.first || User.new(name: "Jane Doe", email: "jane@example.com")
    UserMailer.email_verification(user)
  end
end
