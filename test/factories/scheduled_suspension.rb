Factory.define :scheduled_suspension do |s|
  s.start_date  Date.today - 5
  s.duration    8
  s.active      false
  s.association :subscription, :factory => :active_subscription
end
