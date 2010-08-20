Feature: An admin can CRUD a gift
  As a user with the admin role
  I want to be able to Create, Update and Delete gifts and attach a picture to them

@active
Scenario: I want to see a list of gifts 
#    Given an admin exists with login: "admin_a"
#    Given I am logged in as admin: "AdminA"
    Given I am on the gifts page
    Then I should see "All Gifts"
    And I should see the list of gifts
    And I should see "Create New Gift"

@active
Scenario: An admin goes to the "Create New Gift" page
  Given I am on the gifts page
  When I press "Create New Gift"
  Then I should be on "Create New Gift" page
  And I should see "Name"
  And I should see "Description"
  And I should see "On Hand"
  And I should see "Gift Image"

@pending
Scenario: An admin can create a gift
  Given I am on the "Create New Gift" page
  And I fill in "Name" with "Gift Name"
  And I fill in "Description" with "Gift Description"
  And I fill in "On Hand" with "6"
  And I attach the file "features/data/file.jpg" to "Gift Image"
  And I press "Create"
  Then I should be on the "gifts" page
  And I should see "All Gifts"
  And I should see "Gift Name"
  And I should see "Delete"
  And I should see "Edit"

@pending
Scenario: An Admin can view a gift
  Given I am on the gifts page
  When I press "Gift Name"
  Then I should be on the page: "Gift Name" 
  And I should see "View Gift"
  And I should see "Gift Name"
  And I should see "Delete"
  And I should see "Edit"
  And I should see "Back to Gifts"

@pending
Scenario: An Admin can edit a gift
  Given I am on the "EditGift" page
  And a gift: "Gift Name" exists
  And I fill in "Name" with "New Gift Name"
  And I fill in "Description" with "New Gift Description"
  And I fill in "On Hand" with "7"
  And I attach the file "features/data/new_file.jpg" to "Gift Image"
  And I press "Update"
  Then I should be on the page: "New Gift Name"
  And I should see "Updated Gift: New Gift Name"
  And I should see "View Gift"
  And I should see "New Gift Name"
  And I should see "Delete"
  And I should see "Edit"
  And I should see "Back to Gifts"

@pending
Scenario: An Admin can delete a gift
 Given I am on the gifts page 
 And a gift: "Gift Name" exists
 And I press "Delete"
 Then I should be on the gifts page
 Then I should see "All Gifts"
 And I should see "Gifts List"
 And I should see "Create New Gift"
 And I should not see "Gift Name"
