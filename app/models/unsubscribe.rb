class Unsubscribe < ActionMailer::Base
  
  def notify(user)
    recipients     "subs@crikey.com.au"
    subject        "Crikey Unsubscribe - Please Process"
    from           NO_REPLY
    body           :user => user
    content_type   'text/plain'
  end

end
