Feature: A new user can subscribe to a publication

  Background:
    Given a publication: "A Publication" exists with name: "A Publication"
      And an offer: "An Offer" exists with name: "An Offer", id: 1, publication: publication "A Publication"
      And an offer_term: "Term 1" exists with price: 100, months: 3, offer: offer "An Offer"
      And an offer_term: "Term 2" exists with price: 200, months: 6, offer: offer "An Offer"
      And an offer: "An Offer with gifts" exists with name: "An Offer with gifts", id: 2, publication: publication "A Publication"
      And an offer_term: "Term 3" exists with price: 100, months: 3, offer: offer "An Offer with gifts"
      And a gift: "My Gift" exists with name: "My Gift", id: 1, on_hand: 100
      And a gift: "My Gift 2" exists with name: "My Gift 2", id: 2, on_hand: 100
      And a gift: "My Gift 3" exists with name: "My Gift 3", id: 3, on_hand: 100
      And a gift_offer: "GO1" exists with offer: offer "An Offer with gifts", gift: gift "My Gift", included: true
      And a gift_offer: "GO2" exists with offer: offer "An Offer with gifts", gift: gift "My Gift 2", included: true

  @active
  Scenario: I can subscribe to an offer and pay by Credit Card
    Given I am on the subscribe new page for 1
      And I choose "Offer 1: 3 months"
      And I fill in my details on the subscribe form
      And I choose "Credit Card"
      And I fill in my Credit Card details
      And I check "subscription_terms"
      And I press "btnSubmit"
    Then I should be on the subscribe thanks page

  @active @allow-rescue
  Scenario: I want to subscribe to an offer but my Credit Card is declined
    Given my Credit Card will decline
      And I am on the subscribe new page for 1
      And I choose "Offer 1: 3 months"
      And I fill in my details on the subscribe form
      And I choose "Credit Card"
      And I fill in my Credit Card details
      And I check "subscription_terms"
      And I press "btnSubmit"
    Then I should be on the subscribe page
      And I should see "Test Failure"
    When my Credit Card will succeed
      And I press "btnSubmit"
    Then I should be on the subscribe thanks page

  @active @allow-rescue
  Scenario: I want to subscribe to an offer but on the first attempt I do not enter my details properly
    Given I am on the subscribe new page for 1
      And I choose "Offer 1: 3 months"
      And I choose "Credit Card"
      And I fill in my Credit Card details
      And I check "subscription_terms"
      And I press "btnSubmit"
    Then I should be on the subscribe page
      And I should see "errors prohibited this subscription from being saved"
    When I fill in my details on the subscribe form
      And I press "btnSubmit"
    Then I should be on the subscribe thanks page

  @active @allow-rescue
  Scenario: I want to subscribe to an offer but one of the gifts I have chosen becomes out of stock just before I submit
    Given I am on the subscribe new page for 2
    Then I should see "My Gift"
      And I should see "My Gift 2"
    Then I fill in my details on the subscribe form
      And I choose "Credit Card"
      And I fill in my Credit Card details
      And I check "subscription_terms"
      And the gift "My Gift" runs out of stock
      And I press "btnSubmit"
    Then I should be on the subscribe page
      And I should see "The Gift My Gift is no longer available"
    When I fill in my details on the subscribe form
      And I press "btnSubmit"
    Then I should be on the subscribe thanks page

