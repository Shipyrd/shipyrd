class UserMailer < ApplicationMailer
  def email_verification(user)
    @user = user
    @verification_url = email_verification_url(user.generate_token_for(:email_verification))

    mail to: @user.email, subject: "Shipyrd: Verify your email address"
  end
end
