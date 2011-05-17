Factory.define :subscription_action do |s|
  s.offer_name  { Faker::Name.name }
  s.applied_at  Date.today.to_datetime
  s.term_length 3
  s.association :subscription, :factory => :subscription
  s.association :payment, :factory => :payment
end

Factory.define :pending_subscription_action, :parent => :subscription_action do |s|
  s.applied_at { nil }
  s.subscription nil
  s.association :payment, :factory => :token_payment
end

Factory.define :pending_payment_subscription_action, :parent => :pending_subscription_action do |s|
  s.applied_at { nil }
  s.subscription nil
  s.association :payment, :factory => :direct_debit_payment
end
