When /^I follow "([^"]*)" and click OK$/ do |text|
  page.evaluate_script("window.alert = function(msg) { return true; }")
  page.evaluate_script("window.confirm = function(msg) { return true; }")
  When %{I follow "#{text}"}
end

Then /^I should see that "([^"]*)"(?: within "([^"]*)")? is invisible$/ do |elem, selector|
  with_scope(selector) do
    page.should have_no_xpath('//*', :text => elem, :visible => false)
  end
end

Then /^I should see that "([^"]*)"(?: within "([^"]*)")? is visible$/ do |elem, selector|
  with_scope(selector) do
    page.should have_xpath('//*', :text => elem, :visible => true)
  end
end
