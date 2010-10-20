# This file supports all of the cucumber sentences that relate to changing states in state_machine

Given(/^do transition to state "canceled" for #{capture_model} existing(?: with #{capture_fields})?$/) do |name, fields|
  s = find_model!(name, fields)
  s.state = "active"
  s.save!
  s.state = "canceled"
  s.save!
end
