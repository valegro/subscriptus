Feature: An admin can CRUD an offer
  As a user with the admin role
  I want to be able to Create, Update and Delete offers and attach a picture to them

Background:
  Given an admin: "AdminA" exists with login: "admin_a"
    And a page: "offers" exists 
    And I am logged in as admin: "AdminA"
    And I am on the offers page
    Then I should see "All Offers"
    And I should see "Offers List"
    And I should see "Create New Offer"

@pending
Scenario: As an Admin I want to attach an offer to a publication
  Given I am on the offers page
  When I press "Create New Offer"
  Then I should be on "New Offer" page
  And I should see "Create New Offer"
  And I should see "Name"
  And I should see "Publication"
  And I should see "Auto renews"
  And I should see "Offer Expires"

@pending
Scenario: As an Admin I want to create the terms of an offer
   Given I am on the offers page
   When I press "Create New Offer"
   Then I should be on "New Offer" page
   And I should see "Create New Offer"
   And I should see "Price"
   And I should see "Term"

@pending
Scenario: As an Admin I want to be able to associate gifts with an offer
   Given I am on the offers page
   When I press "Create New Offer"
   Then I should be on "New Offer" page
   And I should see "Associated Gifts"
   And I should see "Create New Offer"

@pending
Scenario: An admin can create an offer
  Given I am on the "Create New Offer" page
  And I fill in "Name" with "Offer Name"
  And I select in publication: "Publication Name"
  And I check Autorenew: "Check"
  And I select expiry: "Expiry date"
  And I fill in "Price" with "6.00"
  And I select Term: "1 month" 
  And I select Gift: "Gifts"
  And I press "Create"
  Then I should be on the "offers" page
  And I should see "All Offers"
  And I should see "Offer Name"
  And I should see "Delete"
  And I should see "Edit"
 
@pending
Scenario: An Admin can view a offer
  Given I am on the offers page
  When I press "Offer Name"
  Then I should be on the page: "Offer Name" 
  And I should see "Offer Name"
  And I should see "Offer Name"
  And I should see "Publication Name"
  And I should see Autorenew: "Check"
  And I should see "Expiry date"
  And I should see price: "6.00"
  And I should see Term: "1 month" 
  And I should see Gift: "Gifts"
  And I should see "Delete"
  And I should see "Edit"
  And I should see "Back to Offers"

@pending
Scenario: An Admin can edit a offer
  Given I am on the "Edit Offer" page
  And an offer: "Offer Name" exists
  And I fill in "Name" with "New Offer Name"
  And I select in publication: "New Publication Name"
  And I check Autorenew: "Uncheck"
  And I select expiry: "New Expiry date"
  And I fill in "Price" with "7.00"
  And I select Term: "2 months" 
  And I select Gift: "New Gifts"
  And I press "Update"
  Then I should be on the page: "New Offer Name"
  And I should see "Updated Offer: New Offer Name"
  And I should see "View Offer"
  And I should see "New Offer Name"
  And I should see "Delete"
  And I should see "Edit"
  And I should see "Back to Offers"

@pending
Scenario: An Admin can delete a offer
 Given I am on the offers page 
 And a offer: "Offer Name" exists
 And I press "Delete"
 Then I should be on the offers page
 Then I should see "All Offers"
 And I should see "Offers List"
 And I should see "Create New Offer"
 And I should not see "Offer Name"





 