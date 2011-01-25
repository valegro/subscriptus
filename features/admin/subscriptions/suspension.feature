Feature: Suspend a subscription
  In order to suspend extend a user's subscription period
  As an admin
  I want to temporarily suspend a user's subscription

  Background:
    Given an admin: "Homer" exists
      And a publication: "p01" exists with name: "publication 01"
      And a publication: "p02" exists with name: "publication 02"
      And an offer: "o01" exists with publication: publication "p01"
      And an offer: "o02" exists with publication: publication "p02"
      And a user: "u01" exists with firstname: "f01", lastname: "l01", email: "u01@example.com", email_confirmation: "u01@example.com"
      And a user: "u02" exists with firstname: "f02", lastname: "l02", email: "u02@example.com", email_confirmation: "u02@example.com"
      And a subscription: "sub1" exists with publication: publication "p01", user: user "u01", state: "active"
      And a subscription: "sub2" exists with publication: publication "p02", user: user "u02", state: "suspended"
      And subscription "sub1" expires in "30" days
      And subscription "sub2" expires in "61" days
      And subscription "sub2"'s current state expires in "30" days
    When I log in as admin "Homer"
    Given I am on admin subscription search page
  
  Scenario: An admin can suspend a subscription
    Then I should see the following table rows:
    | Name    | State     | Renewal Due   |
    | f01 l01 | active    | 30 days       |
    | f02 l02 | suspended | 2 months      |
    When I follow "Suspend"
     And I fill in "Number of days to suspend subscription" with "31"
     And I press "Suspend"
    Then I should see "Subscription to publication 01 for f01 l01 suspended for 31 days"
     And I should be on admin subscription search page
     And I should not see "active"
     And I should see the following table rows:
     | Name    | State     | Renewal Due |
     | f02 l02 | suspended | 2 months    |
     | f01 l01 | suspended | 2 months    |
  
  Scenario: An admin can un-suspend a subscription
  When I follow "Unsuspend"
  Then I should see "Subscription to publication 02 for f02 l02 is now active"
   And I should be on admin subscription search page
   And I should not see "suspended"
   And I should see the following table rows:
   | Name    | State  | Renewal Due |
   | f01 l01 | active | 30 days     |
   | f02 l02 | active | 30 days     |

  
  
  
  
  

  
