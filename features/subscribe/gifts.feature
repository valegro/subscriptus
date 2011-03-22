Feature: A user can choose a gift when they subscribe to an offer

  Background:
    Given a publication: "A Publication" exists with name: "A Publication"
      And an offer: "An Offer" exists with name: "An Offer", id: 1, publication: publication "A Publication"
      And a gift: "My Gift" exists with name: "My Gift", id: 1
      And a gift: "My Gift 2" exists with name: "My Gift 2", id: 2
      And a gift: "My Gift 3" exists with name: "My Gift 3", id: 3

  Scenario: I can subscribe to an offer with a single included gift
    Given a gift_offer exists with gift: gift "My Gift", offer: offer "An Offer", included: true
      And I am on the subscribe page for 1
    Then I should see "Subscribe and Receive"

  Scenario: I can subscribe to an offer with a single optional gift
    Given a gift_offer exists with gift: gift "My Gift", offer: offer "An Offer", included: false
      And I am on the subscribe page for 1
    Then I should see "Subscribe and Receive"

  Scenario: I can subscribe to an offer with two optional gifts
    Given a gift_offer exists with gift: gift "My Gift", offer: offer "An Offer", included: false
      And a gift_offer exists with gift: gift "My Gift 2", offer: offer "An Offer", included: false
      And I am on the subscribe page for 1
    Then I should see "Choose a gift!"

  Scenario: I can subscribe to an offer with one optional and one included gift
    Given a gift_offer exists with gift: gift "My Gift", offer: offer "An Offer", included: false
      And a gift_offer exists with gift: gift "My Gift 2", offer: offer "An Offer", included: true
      And I am on the subscribe page for 1
    Then I should see "Subscribe and Receive"

  Scenario: I can subscribe to an offer with one optional and two included gifts
    Given a gift_offer exists with gift: gift "My Gift", offer: offer "An Offer", included: false
      And a gift_offer exists with gift: gift "My Gift 2", offer: offer "An Offer", included: true
      And a gift_offer exists with gift: gift "My Gift 3", offer: offer "An Offer", included: false
      And I am on the subscribe page for 1
    Then I should see "Subscribe and Receive"
      And I should see "Plus, choose one of the following:"

