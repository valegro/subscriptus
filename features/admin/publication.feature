Feature: An admin can CRUD a publication
  As a user with the admin role
  I want to be able to Create, Update and Delete publications and attach a picture to them

Background:
  Given an admin: "AdminA" exists with login: "admin_a"
    And a page: "publications" exists 
    And I am logged in as admin: "AdminA"
    And I am on the publications page
    Then I should see "All Publications"
    And I should see "Publications List"
    And I should see "Create New Publication"

@pending
Scenario: An admin goes to the "Create New Publication" page
  Given I am on the publications page
  When I press "Create New Publication"
  Then I should be on "Create New Publication" page
  And I should see "Name"
  And I should see "Description"
  And I should see "On Hand"
  And I should see "Publication Image"

@pending
Scenario: An admin can create a publication
  Given I am on the "Create New Publication" page
  And I fill in "Name" with "Publication Name"
  And I fill in "Description with "Publication Description"
  And I fill in "On Hand" with "6"
  And I attach the file "features/data/file.jpg" to "Publication Image"
  And I press "Create"
  Then I should be on the "publications" page
  And I should see "All Publications"
  And I should see "Publication Name"
  And I should see "Delete"
  And I should see "Edit"

@pending
Scenario: An Admin can view a publication
  Given I am on the publications page
  When I press "Publication Name"
  Then I should be on the page: "Publication Name" 
  And I should see "View Publication"
  And I should see "Publication Name"
  And I should see "Delete"
  And I should see "Edit"
  And I should see "Back to Publications"

@pending
Scenario: An Admin can edit a publication
  Given I am on the "EditPublication" page
  And a publication: "Publication Name" exists
  And I fill in "Name" with "New Publication Name"
  And I fill in "Description with "New Publication Description"
  And I fill in "On Hand" with "7"
  And I attach the file "features/data/new_file.jpg" to "Publication Image"
  And I press "Update"
  Then I should be on the page: "New Publication Name"
  And I should see "Updated Publication: New Publication Name"
  And I should see "View Publication"
  And I should see "New Publication Name"
  And I should see "Delete"
  And I should see "Edit"
  And I should see "Back to Publications"

@pending
Scenario: An Admin can delete a publication
 Given I am on the publications page 
 And a publication: "Publication Name" exists
 And I press "Delete"
 Then I should be on the publications page
 Then I should see "All Publications"
 And I should see "Publications List"
 And I should see "Create New Publication"
 And I should not see "Publication Name"
