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
     When I log in as admin "Homer"
      And I go to the admin orders page
        
  Scenario: An admin can view a gift order
    When I follow "View"
    Then show me the page
    Then I should see "Marge Simpson"
     And I should see "Springfield Weekly (12 Month Subscription)"
     And I should see "A case of Duff Beer"

  
  
  

  
