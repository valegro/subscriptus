# This file supports all of the cucumber sentences that relate to changing states in state_machine

Given(/^cancel #{capture_model} existing(?: with #{capture_fields})?$/) do |name, fields|
  s = find_model!(name, fields)
  s.state = "active"
  s.save!
  s.state = "cancelled"
  s.save!
end

Then(/^#{capture_model} state should be "([^"]*)"$/) do |name, state|
  model!(name).state.should == state
end

Given(/^#{capture_model} has state: "([^"]*)"$/) do |name, state|
  model!(name).update_attributes(:state => state)
end
