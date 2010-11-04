Factory.define :subscription do |s|
  s.association :offer, :factory => :offer
  s.association :user, :factory => :subscriber
  s.association :publication, :factory => :publication
  # s.association :publication, :factory => :publication
  # s.association :source, :factory => :source
  s.expires_at Time.parse('2010-12-05')
  s.created_at Time.parse('2010-10-05')
  s.state            { "trial" }
  s.price           30
end
