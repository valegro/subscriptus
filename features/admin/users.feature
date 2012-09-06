Feature: An admin can manage admins
  In order to allow other users to be admins
  As an admin
  I want to be able to CRUD other admins
  
  Background:
    Given an admin: "Homer" exists
      When I log in as admin "Homer"
  
  Scenario: An admin can create another admin
    When I go to the new admin system user page
     And I fill in "Login" with "krusty"
     And I fill in "Firstname" with "Krusty"
     And I fill in "Lastname" with "The Clown"
     And I fill in "Email" with "krusty@springfield.example.com"
     And I fill in "Password" with "wahehey"
     And I fill in "Password confirmation" with "wahehey"
     And I press "Create"
    Then I should see "Created Admin 'Krusty The Clown'."
     And I should be on the admin system users page
  
  Scenario: An admin can edit an admin's details
    Given I am on the admin system users page
     When I follow "Edit"
     When I fill in "Email" with "homer.j.simpson@springfield.example.com"
      And I press "Update"
     Then a user should exist with email: "homer.j.simpson@springfield.example.com"
     
  @javascript 
  Scenario: An admin can delete another admin
    Given an admin: "Marge" exists with firstname: "Marge", lastname: "Simpson"
      And I am on the admin system users page
      And I follow "Delete"
     Then I should see "Admin 'Marge Simpson' has been deleted."
  
  Scenario: An admin cannot delete themselves
    Given I am on the admin system users page
     Then I should not see "Delete"
