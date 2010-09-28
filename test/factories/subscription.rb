Factory.define :subscription do |s|
  s.association :offer, :factory => :offer
  s.association :user, :factory => :user
  s.expires_at Time.parse('2010-12-05')
  s.created_at Time.parse('2010-10-05')
end

