Factory.define :subscription_action do |s|
  s.offer_name  { Faker::Name.name }
  s.applied_at  Date.today.to_datetime
  s.term_length 3
  s.association :subscription, :factory => :subscription
  s.price       30
end
