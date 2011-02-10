Feature: Orders
  In order to manage customer orders
  As an admin
  I want to be able to view and manage orders
  
  Background:
    Given an admin: "Homer" exists
      And a user "Marge" exists with firstname: "Marge", lastname: "Simpson"
      And a gift "the gift" exists with name: "A case of Duff Beer"
      And an offer "the offer" exists with name: "Springfield Weekly (12 Month Subscription)"
      And a gift offer exists with gift: gift "the gift", offer: offer "the offer"
      And a subscription "the sub" exists with offer: offer "the offer", user: user "Marge"
      And a subscription gift exists with gift: gift "the gift", subscription: subscription "the sub"
      And the subscription is activated
     Then an order should exist
     When I log in as admin "Homer"
      And I go to the admin orders page
        
  Scenario: An admin can view a gift order
    When I follow "View"
    Then I should see "Marge Simpson"
     And I should see "Springfield Weekly (12 Month Subscription)"
     And I should see "A case of Duff Beer"
  
  @javascript
  Scenario: An admin can mark a pending gift order as fulfilled
    When I follow "Fulfill" and click OK
     And the order state should be "completed"
     And I should see "There are currently no records."
    When I follow "Completed"
    Then I should see "Marge Simpson"

  @javascript
  Scenario: An admin can mark a delayed gift order as fulfilled
   Given an order exists with state: "delayed", user: user "Marge"
    When I go to the delayed admin orders page
    When I follow "Fulfill" and click OK
    Then the order state should be "completed"
     And I should see "There are currently no records."
    When I follow "Completed"
    Then I should see "Marge Simpson"

  
  
  

  
