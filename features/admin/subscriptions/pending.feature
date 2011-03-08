Feature: Pending Subscription List
  In order to manage pending subscriptions
  As an admin
  I want to be able to view and change pending subscriptions

  Background:
    Given an admin: "Admin" exists
      And a subscriber: "Bob" exists
      And a subscriber: "Alice" exists
      And a publication: "Publication 1" exists with name: "Publication 1"
      And a publication: "Publication 2" exists with name: "Publication 2"
      And a publication: "Publication 3" exists with name: "Publication 3"
     When I log in as admin "Admin"

  @active
  Scenario: An Admin can view all pending subscriptions
    Given a subscription: "Pending Concession Subscription" exists with publication: publication "Publication 3", user: subscriber "Bob", state: "pending", pending: "concession", id: 3
      And I am on the admin pending subscriptions page
     Then I should see "Pending Subscriptions"
      And I should see "Publication 3"
      And I should see "Verify"
      And I should see "Cancel"
      And I should not see "Publication 1"

  @active
  Scenario: An Admin can verify a subscription that is pending concession verification
    Given a subscription: "Pending Concession Subscription" exists with publication: publication "Publication 3", user: subscriber "Bob", state: "pending", pending: "concession", id: 3
      And I am on the admin verify subscription page for 3
      And I fill in "Note" with "Subscriber has a valid student concession card"
      And I press "Verify"
     Then I should see "Verified Subscription"
      And I should be on the admin pending subscriptions page
    Given I am on the admin subscriptions page
     Then I should see "Pending -> Active"
      And I should see "Concession: Subscriber has a valid student concession card"

  @active
  Scenario: An Admin can verify a subscription that is pending payment
    Given a subscription: "Pending Payment Subscription" exists with publication: publication "Publication 2", user: subscriber "Alice", state: "pending", pending: "payment", id: 4, price: 50
      And I am on the admin verify subscription page for 4
      And I select "Direct debit" from "Payment type"
      And I fill in "Reference" with "12345"
      And I press "Verify"
     Then I should see "Verified Subscription"
      And I should be on the admin pending subscriptions page
    Given I am on the admin subscriptions page
     Then I should see "Pending -> Active"
      And I should see "$50.00 by Direct debit (Ref: 12345)"

  @active
  Scenario: An Admin can cancel a subscription that is pending
    Given a subscription: "Pending Payment Subscription" exists with publication: publication "Publication 2", user: subscriber "Alice", state: "pending", pending: "payment", id: 4, price: 50
      And I am on the admin pending subscriptions page
      And I follow "Cancel"
      And I am on the admin pending subscriptions page
      And I should not see "Publication 2"
    
  Scenario: An admin cannot verify a pending subscription twice
    Given a subscription: "Pending Payment Subscription" exists with publication: publication "Publication 2", user: subscriber "Alice", state: "pending", pending: "payment", id: 4, price: 50
      And I am on the admin verify subscription page for 4
      And the subscription "Pending Payment Subscription" has state: "active"
      And I select "Direct debit" from "Payment type"
      And I fill in "Reference" with "12345"
      And I press "Verify"
     Then I should not see "Verified Subscription"
      And I should see "Subscription has already been verified"

