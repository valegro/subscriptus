Factory.define :subscription do |s|
  s.association :offer, :factory => :offer
  s.association :user, :factory => :subscriber
  s.association :publication, :factory => :publication
  # s.association :source, :factory => :source
  # s.expires_at      Date.today.advance(:days => 30).to_datetime
  s.created_at      Date.today.to_datetime
  s.state           { "trial" }
  s.price           30
  s.gifts {|ap| [ap.association(:gift, :on_hand => 1)]}
end

Factory.define :expiring_subscription, :parent => :subscription do |s|
  s.expires_at      Date.today.advance(:days => 30).to_datetime
end

