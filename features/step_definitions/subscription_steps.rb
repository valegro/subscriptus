Given(/^#{capture_model} expires in "([^"]*)" days$/) do |name, days|
  subscription = model!(name)
  subscription.update_attributes(:expires_at => Date.today.advance(:days => days.to_i).to_datetime)
end

Given(/^#{capture_model}'s current state expires in "([^"]*)" days$/) do |name, days|
  subscription = model!(name)
  subscription.update_attributes(:state_expires_at => Date.today.advance(:days => days.to_i).to_datetime)
end

Given(/^#{capture_model} has no expiry date$/ )do |name|
  subscription = model!(name)
  subscription.update_attributes(:expires_at => nil)
end

Given(/^#{capture_model} is activated$/) do |name|
  subscription = model!(name)
  subscription.activate!
end

Given(/^#{capture_model} is suspended for "([^"]*)" days$/) do |name, days|
  subscription = model!(name)
  subscription.suspend!(days.to_i)
end

Given(/^#{capture_model} is unsuspended$/) do |name|
  subscription = model!(name)
  subscription.unsuspend!
end

Given /^I should not be able to select the "([^"]*)" option from "([^"]*)"$/ do |option, select|
  if page.respond_to? :should
    lambda { select(option, :from => select) }.should raise_exception(Capybara::OptionNotFound)
  end
end
