Feature: Subscription List
  In order to CRUD subscriptions
  As an admin
  I want to be able to view different types of subscriptions
  
  Background:
    Given an admin: "Admin" exists
      And the time is "2011-01-01 10:00"
      And a subscriber: "Bob" exists with firstname: "Bob", lastname: "Subscriber"
      And a subscriber: "Alice" exists with firstname: "Alice", lastname: "Subscriber"
      And a publication: "Publication 1" exists with name: "Publication 1"
      And a publication: "Publication 2" exists with name: "Publication 2"
      And a publication: "Publication 3" exists with name: "Publication 3"
      And a subscription exists with publication: publication "Publication 1", user: subscriber "Bob"
      And a subscription exists with publication: publication "Publication 2", user: subscriber "Alice", state: "active"
     When I log in as admin "Admin"
  
  Scenario: An admin can view a list of subscriptions
    When I go to the admin subscriptions page
    Then I should see the following table rows in any order:
      | User             | Publication   | State     |
      | Bob Subscriber   | Publication 1 | New Trial |
      | Alice Subscriber | Publication 2 | Active    |
  
  Scenario: An admin can view a list of subscriptions even if a publication has been deleted
   Given publication "Publication 1" has been deleted
    When I go to the admin subscriptions page
    Then I should see the following table rows in any order:
      | User             | Publication   | State     | Activity | At |
      | Bob Subscriber   | Publication 1 | New Trial |          | 10:30 01/01/2011 EST   |
      | Alice Subscriber | Publication 2 | Active    |          | 10:30 01/01/2011 EST   |
  
