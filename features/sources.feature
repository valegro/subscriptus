Feature: An admin can CRUD a source
  As a user with the admin role
  I want to be able to Create, Update and Delete sources

  @active
  Scenario: I want to see a list of sources 
    Given I am on the admin sources page
      Then the following sources exist
        | code      | description |
        | Email | An email thingy |
      And I should see "Create New Source"

  @active
  Scenario: An admin goes to the "Create New Source" page
    Given I am on the admin sources page
      When I follow "Create New Source"
      Then I should be on the "admin sources new" page

  @active
  Scenario: An admin fails to create a New Source
    Given I am on the "admin sources new" page
      When I fill in "Code" with ""
        And I fill in "Description" with ""
        And I press "Create"
      Then I should see "There were problems with the following fields"
        And I should see "Code"
        And I should see "Description"

  @active
  Scenario: An admin successfully creates a New Source
    Given I am on the "admin sources new" page
      When I fill in "Code" with "Email"
        And I fill in "Description" with "Crikey's shizzle"
        And I press "Create"
      Then I should see "Created Source"
        And I should be on the admin sources page

  @active
  Scenario: An admin can return from the new page to the sources page
    Given I am on the "admin sources new" page
      When I follow "Back to Sources"
      Then I should be on the admin sources page

  @active
  Scenario: An admin can edit a source from the index page
    Given a source: "Email" exists with code: "Email", id: 1, description: "Foo"
      When I am on the admin sources page
        And I follow "Edit"
    Then I should be on the admin sources edit page for 1

  @active
  Scenario: And admin fails to edit a source
    Given a source: "Email" exists with name: "Email", id: 1
      When I am on the admin sources edit page for 1
        And I fill in "Code" with ""
        And I fill in "Description" with ""
        And I press "Update"
      Then I should see "There were problems with the following fields"
        And I should see "Code"
        And I should see "Description"

  @active
  Scenario: An admin edits a source
    Given a source: "Email" exists with name: "Email", id: 1
      When I am on the admin sources edit page for 1
        And I fill in "Code" with "Affiliate"
        And I fill in "Description" with "The quick brown fox jumps over the lazy dog"
        And I press "Update"
      Then I should see "Updated Source: Affiliate"
        And I should see "Affiliate"
        And I should be on the admin sources page

  @active
  Scenario: An admin can delete a source from the sources page
    Given a source: "Email" exists with name: "Email", id: 1
      When I am on the admin sources page
        And I follow "Delete"
      Then I should see "Deleted Source"
        And I should be on the admin sources page
