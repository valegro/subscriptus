Feature: An admin can CRUD a publication
  As a user with the admin role
  I want to be able to Create, Update and Delete publications and attach a picture to them

  Background:
    Given an admin: "Homer" exists
      When I log in as admin "Homer"

  @active
  Scenario: I want to see a list of publications 
    Given I am on the admin catalogue publications page
      Then the following publications exist
        | name      |
        | Daily Mail |
      And I should see "Create New Publication"

  @active
  Scenario: An admin goes to the "Create New Publication" page
    Given I am on the admin catalogue publications page
      When I follow "Create New Publication"
      Then I should be on the "admin catalogue publications new" page

  @active
  Scenario: An admin fails to create a New Publication
    Given I am on the "admin catalogue publications new" page
      When I fill in "Name" with ""
        And I fill in "Description" with ""
        And I press "Create"
      Then I should see "There were problems with the following fields"
        And I should see "Name"
        And I should see "Description"

  @active
  Scenario: An admin successfully creates a New Publication
    Given I am on the "admin catalogue publications new" page
      When I fill in "Name" with "The Daily Mail"
        And I attach the file "features/data/file.jpg" to "Publication image"
        And I fill in "Description" with "Crikey's daily shizzle"
        And I press "Create"
      Then I should see "Created Publication"
        And I should be on the admin catalogue publications page

  @active
  Scenario: An admin can return from the new page to the publications page
    Given I am on the "admin catalogue publications new" page
      When I follow "Back to Publications"
      Then I should be on the admin catalogue publications page

  @active
  Scenario: An Admin can view a publication
    Given a publication: "Daily Mail" exists with name: "Daily Mail", id: 1
      When I am on the admin catalogue publications page
        And I follow "Daily Mail"
    Then I should be on the admin catalogue publication page for 1
      And I should see "Daily Mail"

  @active
  Scenario: An admin can return to Publications from show page
    Given a publication: "Daily Mail" exists with name: "Daily Mail", id: 1
      When I am on the admin catalogue publication page for 1
        And I follow "Back to Publications"
    Then I should be on the admin catalogue publications page

  @active
  Scenario: An admin can edit a publication from the index page
    Given a publication: "Daily Mail" exists with name: "Daily Mail", id: 1
      When I am on the admin catalogue publications page
        And I follow "Edit"
    Then I should be on the admin catalogue publication edit page for 1

  @active
  Scenario: An admin can edit a publication from show page
    Given a publication: "Daily Mail" exists with name: "Daily Mail", id: 1
      When I am on the admin catalogue publication page for 1
        And I follow "Edit"
    Then I should be on the admin catalogue publication edit page for 1

  @active
  Scenario: And admin fails to edit a publication
    Given a publication: "Daily Mail" exists with name: "Daily Mail", id: 1
      When I am on the admin catalogue publication edit page for 1
        And I fill in "Name" with ""
        And I fill in "Description" with ""
        And I press "Update"
      Then I should see "There were problems with the following fields"
        And I should see "Name"
        And I should see "Description"

  @active
  Scenario: And admin edits a publication
    Given a publication: "Daily Mail" exists with name: "Daily Mail", id: 1
      When I am on the admin catalogue publication edit page for 1
        And I fill in "Name" with "Another Book"
        And I fill in "Description" with "The quick brown fox jumps over the lazy dog"
        And I press "Update"
      Then I should see "Updated Publication: Another Book"
        And I should see "Another Book"
        And I should be on the admin catalogue publication page for 1

  @publication
  Scenario: An admin can delete a publication from the publications page
    Given a publication: "Daily Mail" exists with name: "Daily Mail", id: 1
      When I am on the admin catalogue publications page
        And I follow "Delete"
      Then I should see "Deleted Publication"
        And I should be on the admin catalogue publications page
    
  @publications
  Scenario: An admin can delete a publication from the show page
    Given a publication: "Daily Mail" exists with name: "Daily Mail", id: 1
      When I am on the admin catalogue publication page for 1
        And I follow "Delete"
      Then I should see "Deleted Publication"
        And I should be on the admin catalogue publications page
