# This fixes an issue with the API compatibility of the 
# latest selenium webdriver (required due to new version of Firefox)
# and the versions of Cucumber and Capybara that we need to run due 
# to the fact that this app is on 2.3.x
Capybara::Driver::Selenium::Node.class_eval do
  def select_option
    native.click unless selected?
  end
end