require 'cm/recipient'

r = CM::Recipient.update(:created_at => Time.now, :from_ip => '127.0.0.1', :email => 'daniel2@netfox.com', :id => 10, :last_modified_by => 'me')
puts r
