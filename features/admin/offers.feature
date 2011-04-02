Feature: An admin can CRUD an Offer
  As a user with the admin role
  I want to be able to Create, Update and Delete offers

  Background:
    Given an admin: "Homer" exists
      When I log in as admin "Homer"

  @active
  Scenario: An admin goes to the "Create New Offer" page
    Given I am on the admin catalogue offers page
      When I follow "Create New Offer"
      Then I should be on the "admin catalogue offers new" page

  @active
  Scenario: An admin fails to create a New Offer
    Given I am on the "admin catalogue offers new" page
      When I fill in "Name" with ""
      When I fill in "Price" with "jhgjhg"
        And I press "Create"
      Then I should see "There were problems with the following fields"
        And I should see "Name"
        And I should see "Price"

  @active
  Scenario: An admin successfully creates a New Offer
    Given I am on the "admin catalogue offers new" page
      When I fill in "Name" with "An offer"
        And I fill in "Price" with "10"
        And I press "Create"
      Then I should be on the admin catalogue offers page

  @active
  Scenario: An admin can return from the new page to the offers page
    Given I am on the "admin catalogue offers new" page
      When I follow "Back to Offers"
      Then I should be on the admin catalogue offers page

  @active
  Scenario: An Admin can view an offer
    Given an offer: "An Offer" exists with name: "An Offer", id: 1
      When I am on the admin catalogue offers page
        And I follow "An Offer"
    Then I should be on the admin catalogue offer page for 1
      And I should see "An Offer"
      And I should see "Term Options"
      And I should see "Gift Options"
      And I should see "Promote"

  @active
  Scenario: An admin can return to Offers from show page
    Given an offer: "An Offer" exists with name: "An Offer", id: 1
      When I am on the admin catalogue offer page for 1
        And I follow "Back to Offers"
    Then I should be on the admin catalogue offers page

  @javascript
  Scenario: An admin can promote an offer
    Given an offer: "An Offer" exists with name: "An Offer", id: 1
      And a source: "Email" exists with code: "Email", id: 10
      And a source: "Affiliate" exists with code: "Affiliate", id: 20
    When I am on the admin catalogue offer page for 1
      And I follow "Promote"
    Then I should see "Generate Link to this Offer"
      And the "offer_link" field should contain "http://offers.crikey.com.au/subscribe?offer_id=1&source=20"
    When I select "Email" from "Source"
      Then the "Link" field should contain "http://offers.crikey.com.au/subscribe?offer_id=1&source=10"

  @javascript
  Scenario: An admin fails to add a term option
    Given an offer: "An Offer" exists with name: "An Offer", id: 1
    When I am on the admin catalogue offer page for 1
      And I follow "add_term_option"
    When I press "Create"
      Then I should see "Add Offer Term Option"

  @javascript
  Scenario: An admin can add a term option
    Given an offer: "An Offer" exists with name: "An Offer", id: 1
      When I am on the admin catalogue offer page for 1
        And I follow "add_term_option"
        And I fill in "offer_term[price]" with "100"
        And I fill in "offer_term[months]" with "3"
        And I press "Create"
      Then I should see "3 months for $100.00" within "#full_price_terms"

  @javascript
  Scenario: An admin can add a term option with a concession
    Given an offer: "An Offer" exists with name: "An Offer", id: 1
      When I am on the admin catalogue offer page for 1
        And I follow "add_term_option"
        And I fill in "offer_term[price]" with "75"
        And I fill in "offer_term[months]" with "3"
        And I check "Concession option"
        And I press "Create"
      Then I should see "3 months for $75.00" within "#concession_terms"

  @javascript
  Scenario: An Admin can delete a term option
    Given an offer: "An Offer" exists with name: "An Offer", id: 1
      When an offer_term: "OT1" exists with offer: offer "An Offer", id: 10
        And I am on the admin catalogue offer page for 1
      Then I should see "3 months for $22.00" within "#full_price_terms"
      When I follow "delete_term_option" within "#term_option_10"
        Then I should not see "3 months for $22.00" within "#full_price_terms"
          And I should see "No Term Options" within "#full_price_terms"

  @active
  Scenario: An admin can edit an offer details from the index page
    Given an offer: "An Offer" exists with name: "An Offer", id: 1
      When I am on the admin catalogue offers page
        And I follow "Edit"
    Then I should be on the admin catalogue offer page for 1

  @active
  Scenario: An admin can edit an offer from show page
    Given an offer: "An Offer" exists with name: "An Offer", id: 1
      When I am on the admin catalogue offer page for 1
        And I follow "Edit"
    Then I should be on the admin catalogue offer edit page for 1

  @active
  Scenario: And admin fails to edit an offer
    Given an offer: "An Offer" exists with name: "An Offer", id: 1
      When I am on the admin catalogue offer edit page for 1
        And I fill in "Name" with ""
        And I press "Update"
      Then I should see "There were problems with the following fields"
        And I should see "Name"

  @active
  Scenario: And admin edits an offer
    Given an offer: "An Offer" exists with name: "An Offer", id: 1
      When I am on the admin catalogue offer edit page for 1
        And I fill in "Name" with "Another Offer"
        And I press "Update"
      Then I should see "Updated Offer: Another Offer"
        And I should see "Another Offer"
        And I should be on the admin catalogue offer page for 1

  @active
  Scenario: An admin can delete an offer from the gifts page
    Given an offer: "An Offer" exists with name: "An Offer", id: 1
      When I am on the admin catalogue offers page
        And I follow "Delete"
      Then I should see "Deleted Offer"
        And I should be on the admin catalogue offers page
    
  @active
  Scenario: An admin can delete an offer from the show page
    Given an offer: "An Offer" exists with name: "An Offer", id: 1
      When I am on the admin catalogue offer page for 1
        And I follow "Delete"
      Then I should see "Deleted Offer"
        And I should be on the admin catalogue offers page
