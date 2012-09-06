Given(/^I am logged in as #{capture_model}$/) do |name|
  When %{I log in as #{name}}
end

Given(/^I have requested a password reset be sent to "(.+)"$/) do |email|
  Given %{I am on the reset password page}
  When %{I fill in "Email address" with "#{email}"}
  When %{I press "Reset Password"}
end


When(/^I log in as #{capture_model}$/) do |name|
  user = model!(name)
  login = user.login
  password = 'password'
  
  When %{I go to the login page}
  And %{I fill in "Email" with "#{login}"}
  And %{I fill in "Password" with "#{password}"}
  And %{I press "submit"}
end

Then(/#{capture_model} can view (.+)$/) do |name, page_name|
  When %{I go to the logout page} 
  And %{I am logged in as #{name}}
  When %{I go to #{page_name}}
  Then %{I should be on #{page_name}}
end

Then(/#{capture_model} cannot view (.+)$/) do |name, page_name|
  When %{I go to the logout page} 
  And %{I am logged in as #{name}}
  When %{I go to #{page_name}}
  Then %{I should not be on #{page_name}}
end

Then(/^(?:|I )should not be on (.+)$/) do |page_name|
  current_path = URI.parse(current_url).path
  if current_path.respond_to? :should
    current_path.should_not == path_to(page_name)
  else
    assert_not_equal path_to(page_name), current_path
  end
end

When(/^(?:|I )fill in "([^\"]*)" with #{capture_model}'s (.+)$/) do |field, name, model_field|
  fill_in(field, :with => model!(name).send(model_field.to_sym))
end