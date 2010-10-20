# This file supports all of the cucumber sentences that relate to changing states in state_machine

Given(/^cancel #{capture_model} existing(?: with #{capture_fields})?$/) do |name, fields|
  s = find_model!(name, fields)
  s.state = "active"
  s.save!
  s.state = "canceled"
  s.save!
end
