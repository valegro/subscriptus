Feature: An admin can log in or out of the admin interface

  @active
  Scenario: An admin can login
    Given an admin: "Homer" exists
      When I log in as admin "Homer"
    Then I should be on the "admin subscriptions" page

  @active
  Scenario: An admin can logout
    Given an admin: "Homer" exists
      When I log in as admin "Homer"
    Then I should be on the "admin subscriptions" page
      And I follow "logout"
    Then I should be on the "login" page
    
  Scenario: A subscriber can login with their email address
    Given a subscriber: "Bart" exists with email: "bart@simpsons.com", email_confirmation: "bart@simpsons.com", password: "bartman", password_confirmation: "bartman"
     When I go to the login page
      And I fill in "Login" with "bart@simpsons.com"
      And I fill in "Password" with "bartman"
      And I press "Login"
     Then I should not be on the login page
      And I should see "Login successful!"
