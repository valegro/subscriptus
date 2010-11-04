class UserMailer < ActionMailer::Base
  
  def new_user(user)
    recipients user.email
    subject "New Crikey User"
    from "noreply@crikey.com.au"
    body :user => user
    content_type 'text/html'
  end

end
