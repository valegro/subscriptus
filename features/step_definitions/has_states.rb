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

Then(/^#{capture_model} state should not be "([^"]*)"$/) do |name, state|
  model!(name).state.should_not == state
end

Given(/^#{capture_model} has state: "([^"]*)"$/) do |name, state|
  model!(name).update_attributes(:state => state)
end

When(/^#{capture_model} states are expired$/) do |name|
  model!(name).class.expire_states
end
