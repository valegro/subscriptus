Feature: A user can subscribe to an offer with a term option

  Background:
    Given a publication: "A Publication" exists with name: "A Publication"
      And an offer: "An Offer" exists with name: "An Offer", id: 1, publication: publication "A Publication"
      And a gift: "My Gift" exists with name: "My Gift", id: 1

  Scenario: I can choose an offer with one term option
    Given an offer_term exists with months: 3, offer: offer "An Offer", price: 30
      And I am on the subscribe new page for 1
    Then I should see "Choose your Subscription"
      And I should see "3 months"
      And I should see "$30.00"

  Scenario: I can choose an offer with two term options
    Given an offer_term exists with months: 3, offer: offer "An Offer", price: 30
      And an offer_term exists with months: 6, offer: offer "An Offer", price: 55
      And I am on the subscribe new page for 1
    Then I should see "Choose your Subscription"
      And I should see "3 months"
      And I should see "$30.00"
      And I should see "6 months"
      And I should see "$55.00"

  @javascript
  Scenario: I can choose an offer with a student concession
    Given an offer_term exists with months: 3, offer: offer "An Offer", price: 30
      And an offer_term exists with months: 6, offer: offer "An Offer", price: 55
      And an offer_term exists with months: 3, offer: offer "An Offer", price: 10, concession: true
      And an offer_term exists with months: 6, offer: offer "An Offer", price: 20, concession: true
      And I am on the subscribe new page for 1
    Then I should see "Choose your Subscription"
      And I should see that "$20.00" is invisible
    Then I follow "STUDENTS"
      And I should see that "$20.00" is visible
      And I should see that "Get 32% off the normal price of Crikey Subscriber" is visible
      And I should see that "$30.00" is invisible
    Then I follow "SENIOR / CONCESSIONS"
      #And I should see that "$20.00" is visible
      And show me the page
      And I should see that "Get 32% off the normal price of Crikey Subscriber" is visible
      And I should see that "Crikey offers a discount subscription rate of $100 per year to seniors and concession card holders. All you need to do is fill out the online form below and then fax or mail us a copy of your seniors/concession card." is visible
