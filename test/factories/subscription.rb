Factory.define :subscription do |s|
  s.association :offer, :factory => :offer
  s.association :user, :factory => :subscriber
  s.association :publication, :factory => :publication
  s.created_at  Date.today.to_datetime
  s.state       { "trial" }
  s.price       30
end

Factory.define :active_subscription, :parent => :subscription do |s|
  s.state 'active'
  s.expires_at { 2.weeks.from_now }
end

Factory.define :expiring_subscription, :parent => :subscription do |s|
  s.expires_at      Date.today.advance(:days => 30).to_datetime
end

Factory.define :pending_subscription, :parent => :subscription do |s|
  s.association :user, :factory => :user_with_token
  s.state { 'pending' }
  s.pending { 'concession_verification' }
  s.association :pending_action, :factory => :pending_subscription_action
end

Factory.define :pending_payment_subscription, :parent => :subscription do |s|
  s.state { 'pending' }
  s.pending { 'payment' }
  s.association :pending_action, :factory => :pending_payment_subscription_action
end

Factory.define :expired_subscription, :parent => :subscription do |s|
  s.expires_at { 2.hours.ago }
  s.state 'squatter'
end

Factory.define :suspended_subscription, :parent => :subscription do |s|
  s.expires_at { 20.days.from_now }
  s.state 'suspended'
end
