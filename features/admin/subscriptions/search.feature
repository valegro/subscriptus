Feature: Subscription search
  In order to get to crud subscription
  As an admin
  I want to be able to find subscriptions that match criteria

  Background:
    Given an admin: "Homer" exists
      And a publication: "p01" exists with name: "publication 01"
      And a publication: "p02" exists with name: "publication 02"
      And an offer: "o01" exists with publication: publication "p01"
      And an offer: "o02" exists with publication: publication "p02"
      And a user: "u01" exists with firstname: "f01", lastname: "l01", email: "u01@example.com", email_confirmation: "u01@example.com"
      And a user: "u02" exists with firstname: "f02", lastname: "l02", email: "u02@example.com", email_confirmation: "u02@example.com"
      And a subscription exists with publication: publication "p01", user: user "u01", state: "trial"
      And a subscription exists with publication: publication "p02", user: user "u02", state: "active"
    When I log in as admin "Homer"

  @javascript
  Scenario: An admin adds publication field to search form
    Given I am on admin subscription search page
      When I select "Publication" from "filter_name"
      And I follow "Add"
    Then I should see "Publication" within "form div label"

  @javascript
  Scenario: An admin adds name field to search form
    Given I am on admin subscription search page
      When I select "Name" from "filter_name"
      And I follow "Add"
    Then I should see "Name" within "form div label"

  @javascript
  Scenario: An admin adds email field to search form
    Given I am on admin subscription search page
      When I select "Email" from "filter_name"
      And I follow "Add"
    Then I should see "Email" within "form div label"

  @javascript
  Scenario: An admin adds Reference field to search form
    Given I am on admin subscription search page
     When I select "Reference" from "filter_name"
      And I follow "Add"
     Then I should see "Reference" within "form div label"

  @javascript
  Scenario: An admin searches with a publication filter
    Given I am on admin subscription search page
    When I select "Publication" from "filter_name"
      And I follow "Add"
      And I select "publication 01" from "search_publication_id"
      And I press "Search"
    Then I should see "trial"
      And I should see "u01@example.com"
      And I should not see "active"
      And I should see "Displaying 1 subscription"

  @javascript
  Scenario: An admin searches with a name filter
    Given I am on admin subscription search page
      When I select "Name" from "filter_name"
      And I follow "Add"
      And I fill in "search_user_firstname_or_user_lastname_like" with "l01"
      And I press "Search"
    Then I should see "trial"
      And I should see "u01@example.com"
      And I should not see "active"
      And I should see "Displaying 1 subscription"

  @javascript
  Scenario: An admin searches with a email filter
    Given I am on admin subscription search page
      When I select "Email" from "filter_name"
      And I follow "Add"
      And I fill in "search_user_email_like" with "u01"
      And I press "Search"
    Then I should see "trial"
      And I should see "u01@example.com"
      And I should not see "active"
      And I should see "Displaying 1 subscription"

  @javascript
  Scenario: An admin searches with an Reference filter
    Given I am on admin subscription search page
      And a subscription exists with id: 1234, publication: publication "p01", user: user "u01", state: "trial"
      When I select "Reference" from "filter_name"
      And I follow "Add"
      And I fill in "search_id" with "S0001234"
      And I press "Search"
    Then I should see "trial"
      And I should see "u01@example.com"
      And I should not see "active"
      And I should see "Displaying 1 subscription"
      
     When I fill in "search_id" with "s0001234"
      And I press "Search"
     Then I should see "trial"
      And I should see "u01@example.com"
      And I should not see "active"
      And I should see "Displaying 1 subscription"

    When I fill in "search_id" with "1234"
     And I press "Search"
    Then I should see "trial"
     And I should see "u01@example.com"
     And I should not see "active"
     And I should see "Displaying 1 subscription"


  @javascript
  Scenario: An admin searches with a publication with no subscription
    Given a publication: "p03" exists with name: "publication 03"
      And I am on admin subscription search page
    When I select "Publication" from "filter_name"
      And I follow "Add"
      And I select "publication 03" from "search_publication_id"
      And I press "Search"
    Then I should see "No entries found"

  @javascript
  Scenario: An admin searches with a name that does not match any name
    Given I am on admin subscription search page
    When I select "Name" from "filter_name"
      And I follow "Add"
      And I fill in "search_user_firstname_or_user_lastname_like" with "spamspamspamspam"
      And I press "Search"
    Then I should see "No entries found"

  @javascript
  Scenario: An admin searches with a email that does not match any email
    Given I am on admin subscription search page
    When I select "Email" from "filter_name"
      And I follow "Add"
      And I fill in "search_user_email_like" with "emailwithnomatch"
      And I press "Search"
    Then I should see "No entries found"

  Scenario: An admin searches with no filter
    Given I am on admin subscription search page
    When I press "Search"
    Then I should see "Displaying all 2 subscriptions"
      And I should see "publication 01"
      And I should see "publication 02"


  @javascript
  Scenario: An admin searches by publication and result page's form contains publication field
    Given I am on admin subscription search page
    When I select "Publication" from "filter_name"
    And I follow "Add"
    And I select "publication 01" from "search_publication_id"
    And I press "Search"
    Then I should see "Publication" within "form div label"

  Scenario: An admin sorts search results by publication asc
    Given I am on admin subscription search page
    When I press "Search"
    And I follow "Publication"
    #TODO: We have to specify what time zone we use to display time.
    Then I should see the following "search_results" table:
      | Name    | Email           | ▲ Publication  | State  | Renewal Due   | Signed Up  | Actions |
      | f01 l01 | u01@example.com | publication 01 | trial  | about 1 month | 04/10/2010 |         |
      | f02 l02 | u02@example.com | publication 02 | active | about 1 month | 04/10/2010 | Suspend |



  Scenario: An admin sorts search results by publication desc
    Given I am on admin subscription search page
    When I press "Search"
    And I follow "Publication"
    And I follow "▲ Publication"
    Then I should see the following "search_results" table:
      | Name    | Email           | ▼ Publication  | State  |
      | f02 l02 | u02@example.com | publication 02 | active |
      | f01 l01 | u01@example.com | publication 01 | trial  |

  Scenario: An admin sorts search results by subscriber name asc
    Given I am on admin subscription search page
    When I press "Search"
    And I follow "Name"
    Then I should see the following "search_results" table:
      | ▲ Name  | Email           | Publication    | State  |
      | f01 l01 | u01@example.com | publication 01 | trial  |
      | f02 l02 | u02@example.com | publication 02 | active |

  Scenario: An admin sorts search results by subscriber name desc
    Given I am on admin subscription search page
    When I press "Search"
    And I follow "Name"
    And I follow "▲ Name"
    Then I should see the following "search_results" table:
      | ▼ Name  | Email           | Publication    | State  |
      | f02 l02 | u02@example.com | publication 02 | active |
      | f01 l01 | u01@example.com | publication 01 | trial  |

  Scenario: An admin sorts search results by subscriber email asc
    Given I am on admin subscription search page
    When I press "Search"
    And I follow "Email"
    Then I should see the following "search_results" table:
      | Name    | ▲ Email         | Publication    | State  |
      | f01 l01 | u01@example.com | publication 01 | trial  |
      | f02 l02 | u02@example.com | publication 02 | active |

  Scenario: An admin sorts search results by subscriber email desc
    Given I am on admin subscription search page
    When I press "Search"
    And I follow "Email"
    And I follow "▲ Email"
    Then I should see the following "search_results" table:
      | Name    | ▼ Email         | Publication    | State  |
      | f02 l02 | u02@example.com | publication 02 | active |
      | f01 l01 | u01@example.com | publication 01 | trial  |

  @javascript
  Scenario: An admin searches for 22 results and result is paginated
    Given 20 subscriptions exist with offer: offer "o01", user: user "u01", state: "trial"
      And I am on admin subscription search page
    When I press "Search"
      Then I should see "Displaying subscriptions"
      And I should see "« Previous 1 2 Next »"

