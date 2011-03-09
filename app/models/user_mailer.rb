class UserMailer < ActionMailer::Base
  NO_REPLY = "noreply@crikey.com.au"
  def new_user(user)
    recipients user.email
    subject "New Crikey User"
    from NO_REPLY
    body :user => user
    content_type 'text/html'
  end

end
