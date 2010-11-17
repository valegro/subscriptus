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
    
