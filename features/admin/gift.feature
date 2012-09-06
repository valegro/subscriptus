Feature: An admin can CRUD a gift
  As a user with the admin role
  I want to be able to Create, Update and Delete gifts and attach a picture to them

  Background:
    Given an admin: "Homer" exists
      When I log in as admin "Homer"

  @active
  Scenario: I want to see a list of gifts 
    Given I am on the admin catalogue gifts page
      Then the following gifts exist
        | name      | on_hand         |
        | Book | 1 |
      And I should see "Create New Gift"

  @active
  Scenario: An admin goes to the "Create New Gift" page
    Given I am on the admin catalogue gifts page
    When I follow "Create New Gift"
    Then I should be on the "admin catalogue gifts new" page

  @active
  Scenario: An admin fails to create a New Gift
    Given I am on the "admin catalogue gifts new" page
      And I fill in "Name" with ""
      And I fill in "Description" with ""
      And I fill in "On hand" with ""
      And I press "Create"
    Then I should see "There were problems with the following fields"
      And I should see "Name"
      And I should see "Description"

  @active
  Scenario: An admin successfully creates a New Gift
    Given I am on the "admin catalogue gifts new" page
      And I fill in "Name" with "A book"
      And I fill in "Description" with "A great book by a well known author"
      And I fill in "On hand" with "10"
      And I attach the file "features/data/file.jpg" to "Gift image"
      And I press "Create"
    Then I should see "Created Gift"
      And I should be on the admin catalogue gifts page

  @active
  Scenario: An admin can return from the new page to the gifts page
    Given I am on the "admin catalogue gifts new" page
      And I follow "Back to Gifts"
    Then I should be on the admin catalogue gifts page

  @active
  Scenario: An Admin can view a gift
    Given a gift: "My Gift" exists with name: "My Gift", id: 1
      And I am on the admin catalogue gifts page
      And I follow "My Gift"
    Then I should be on the admin catalogue gift page for 1
      And I should see "My Gift"
      And I should see "Stock on hand"

  @active
  Scenario: An admin can return to Gifts from show page
    Given a gift: "My Gift" exists with name: "My Gift", id: 1
      When I am on the admin catalogue gift page for 1
        And I follow "Back to Gifts"
    Then I should be on the admin catalogue gifts page

  @active
  Scenario: An admin can edit a gift from the index page
    Given a gift: "My Gift" exists with name: "My Gift", id: 1
      When I am on the admin catalogue gifts page
        And I follow "Edit"
    Then I should be on the admin catalogue gift edit page for 1

  @active
  Scenario: An admin can edit a gift from show page
    Given a gift: "My Gift" exists with name: "My Gift", id: 1
      When I am on the admin catalogue gift page for 1
        And I follow "Edit"
    Then I should be on the admin catalogue gift edit page for 1

  @active
  Scenario: And admin fails to edit a gift
    Given a gift: "My Gift" exists with name: "My Gift", id: 1
      When I am on the admin catalogue gift edit page for 1
        And I fill in "Name" with ""
        And I fill in "Description" with ""
        And I fill in "On hand" with ""
        And I press "Update"
      Then I should see "There were problems with the following fields"
        And I should see "Name"
        And I should see "Description"

  @active
  Scenario: And admin edits a gift
    Given a gift: "My Gift" exists with name: "My Gift", id: 1
      When I am on the admin catalogue gift edit page for 1
        And I fill in "Name" with "Another Book"
        And I fill in "Description" with "The quick brown fox jumps over the lazy dog"
        And I fill in "On hand" with "-1"
        And I press "Update"
      Then I should see "Updated Gift: Another Book"
        And I should see "Another Book"
        And I should be on the admin catalogue gift page for 1

  @javascript
  Scenario: An admin can delete a gift from the gifts page
    Given a gift: "My Gift" exists with name: "My Gift", id: 1
      When I am on the admin catalogue gifts page
        And I follow "Delete"
      Then I should see "Deleted Gift"
        And I should be on the admin catalogue gifts page
    
  @javascript
  Scenario: An admin can delete a gift from the show page
    Given a gift: "My Gift" exists with name: "My Gift", id: 1
      When I am on the admin catalogue gift page for 1
        And I follow "Delete"
      Then I should see "Deleted Gift"
        And I should be on the admin catalogue gifts page
