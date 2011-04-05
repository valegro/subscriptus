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
