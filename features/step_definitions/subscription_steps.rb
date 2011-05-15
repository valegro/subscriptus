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
    lambda {
      select(option, :from => select)
    }.should raise_exception(Capybara::ElementNotFound)
  end
end

Given /^a subscription is created from #{capture_fields}$/ do |offer|
  #puts capture_model
  
  SubscriptionFactory.build(find_model(offer))
end

Given /^a subscription is created from an offer: "([^"]*)" with #{capture_model}(?: with #{capture_fields})?$/ do |offer, user, user_fields|
  offer_model = find_model(offer)
  user_model = find_model!(user, user_fields)
  subscription = SubscriptionFactory.build(offer_model, :included_gift_ids => offer_model.gifts.included.map(&:id))
  subscription.user = user_model
  subscription.save!
  store_model("subscription", "the sub", subscription)
  subscription
end
