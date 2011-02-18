Feature: Subscription expiry
  In order to know that my trial has ended
  As a user
  I want to know when my trial expires
  
  Scenario: A trial will not expire after 20 days
    Given a subscription exists
      And 20 days have passed
     When the subscription states are expired
     Then the subscription state should not be "squatter"
      And the subscription state should be "trial"
  
  Scenario: A trial will expire after 21 days
    Given a subscription exists
      And 21 days have passed
     When the subscription states are expired
     Then the subscription state should be "squatter"
  
  
  

  
