Feature: An admin can CRUD an Offer
  As a user with the admin role
  I want to be able to Create, Update and Delete offers

  Background:
    Given an admin: "Homer" exists
      When I log in as admin "Homer"

  @active
  Scenario: An admin can list and sort offers
    Given a publication: "A Publication" exists with name: "A Publication"
      And a publication: "B Publication" exists with name: "B Publication"
      And an offer: "An Offer" exists with name: "An Offer", id: 1, publication: publication "A Publication"
      And an offer: "My Offer" exists with name: "My Offer", id: 2, publication: publication "B Publication"
    When I am on the admin catalogue offers page
      Then I should see "An Offer" within "tr[@class=' odd ']"
        And I should see "My Offer" within "tr[@class=' even last']"
    When I follow "Name"
      Then I should see "An Offer" within "tr[@class=' odd ']"
        And I should see "My Offer" within "tr[@class=' even last']"
    When I follow "Name"
      Then I should see "An Offer" within "tr[@class=' even last']"
        And I should see "My Offer" within "tr[@class=' odd ']"
    When I follow "Publication"
      Then I should see "A Publication" within "tr[@class=' odd ']"
        And I should see "B Publication" within "tr[@class=' even last']"
    When I follow "Publication"
      Then I should see "A Publication" within "tr[@class=' even last']"
        And I should see "B Publication" within "tr[@class=' odd ']"
