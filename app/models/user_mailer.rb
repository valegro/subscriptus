class UserMailer < ActionMailer::Base
  NO_REPLY = "noreply@crikey.com.au"

  def password_reset_instructions(user)
    subject       "Password Reset Instructions"
    from          NO_REPLY
    recipients    user.email  
    sent_on       Time.now
    body          :edit_password_reset_link => edit_password_reset_url(user.perishable_token)
  end
end
