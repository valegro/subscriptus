Feature: Orders
  In order to manage customer orders
  As an admin
  I want to be able to view and manage orders
  
  Background:
    Given an admin: "Homer" exists
      And a user "Marge" exists with firstname: "Marge", lastname: "Simpson"

      And a gift "the gift" exists with name: "A case of Duff Beer"
      And a publication "the pub" exists with name: "Springfield Weekly"
      And an offer "the offer" exists with name: "Springfield Weekly (12 Month Subscription)", publication: publication "the pub"
      And a gift offer exists with gift: gift "the gift", offer: offer "the offer"
      And a subscription "the sub" exists with offer: offer "the offer", user: user "Marge", publication: publication "the pub"
      And a subscription gift exists with gift: gift "the gift", subscription: subscription "the sub"
      And the subscription is activated
     Then an order: "the order" should exist
     When I log in as admin "Homer"
      And I go to the admin orders page
  
  Scenario: An admin can download a CSV of pending orders
    When I follow "Export as CSV"
    Then I should see "Marge"
     And I should see "Simpson"
     And I should see "Springfield Weekly"
     And I should see "A case of Duff Beer"
  
  Scenario: An admin can view a gift order
    When I follow "View"
    Then I should see "Marge Simpson"
     And I should see "Springfield Weekly (12 Month Subscription)"
     And I should see "A case of Duff Beer"
  
  Scenario: An admin can view and then fulfill a gift order
    When I follow "View"
     And I follow "Fulfill"
    Then the order: "the order" state should be "completed"
  
  Scenario: An admin can view and then delay a gift order
    When I follow "View"
     And I follow "Delay"
    Then the order: "the order" state should be "delayed"
  
  @javascript
  Scenario: An admin can mark a pending gift order as fulfilled
    When I follow "Fulfill" and click OK
    Then the order: "the order" state should be "completed"
     And I should see "There are currently no records."
    When I follow "Completed"
    Then I should see "Marge Simpson"

  @javascript
  Scenario: An admin can mark a delayed gift order as fulfilled
   Given a user "Bart" exists with firstname: "Bart", lastname: "Simpson"
     And an order: "Bart's order" exists with state: "delayed", user: user "Bart"
    When I go to the delayed admin orders page
    When I follow "Fulfill" and click OK
    Then the order "Bart's order" state should be "completed"
     And I should see "There are currently no records."
    When I follow "Completed"
    Then I should see "Bart Simpson"

  @javascript
  Scenario: An admin can mark a pending gift order as delayed
    When I follow "Delay" and click OK
    Then the order: "the order" state should be "delayed"
     And I should see "There are currently no records."
    When I follow "Delayed"
    Then I should see "Marge Simpson"
  
  Scenario: An admin will be alerted if the user account is missing
    Given the user: "Marge" has been deleted
    When I go to the admin orders page
     And I follow "View"
    Then I should see "The user associated with this order could not be found"
  
  Scenario: An order will still be viewable if the subscription isn't present
   Given subscription: "the sub" has been deleted
    When I follow "View"
    Then I should see "Marge Simpson"
     And I should see "'Subscription offer could not be found."
     And I should see "A case of Duff Beer"
   
  