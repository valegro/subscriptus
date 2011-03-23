Feature: A user can subscribe to an offer with a term option

  Background:
    Given a publication: "A Publication" exists with name: "A Publication"
      And an offer: "An Offer" exists with name: "An Offer", id: 1, publication: publication "A Publication"
      And a gift: "My Gift" exists with name: "My Gift", id: 1

  Scenario: I can subscribe to an offer with one term option
    Given an offer_term exists with months: 3, offer: offer "An Offer", price: 30
      And I am on the subscribe page for 1
    Then I should see "Choose your Subscription"
      And I should see "3 months"
      And I should see "$30.00"

  Scenario: I can subscribe to an offer with two term options
    Given an offer_term exists with months: 3, offer: offer "An Offer", price: 30
      And an offer_term exists with months: 6, offer: offer "An Offer", price: 55
      And I am on the subscribe page for 1
    Then I should see "Choose your Subscription"
      And I should see "3 months"
      And I should see "$30.00"
      And I should see "6 months"
      And I should see "$55.00"
