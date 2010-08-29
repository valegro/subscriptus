require 'cm/recipient'

r = CM::Recipient.create!(
  :created_at => Time.now,
  :from_ip => '127.0.0.1',
  :email => 'daniel2@netfox.com',
  :id => 10,
  :last_modified_by => 'me',
  :fields => { :State => 'trial' }
)
  #:fields => { :State => 'trial', :ExpiresAt => (10.days.from_now) }
puts r
