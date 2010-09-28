Feature: Subscription search
  In order to get to crud subscription
  As an admin
  I want to be able to find subscriptions that match criteria

Background:
  Given a publication: "p01" exists with name: "publication 01"
  And a publication: "p02" exists with name: "publication 02"
  And an offer: "o01" exists with publication: publication "p01"
  And an offer: "o02" exists with publication: publication "p02"
  And a user: "u01" exists with firstname: "f01", lastname: "l01", email: "u01@example.com", email_confirmation: "u01@example.com"
  And a user: "u02" exists with firstname: "f02", lastname: "l02", email: "u02@example.com", email_confirmation: "u02@example.com"
  And a subscription exists with offer: offer "o01", user: user "u01", state: "TRIAL"
  And a subscription exists with offer: offer "o02", user: user "u02", state: "ACTIVE"

  @javascript
  Scenario: An admin adds publication field to search form
    Given I am on admin subscription search page
    When I select "publication" from "filter_name"
    And I follow "Add"
    Then I should see "Publication" within "form div label"

  @javascript
  Scenario: An admin searches with a publication filter
    Given I am on admin subscription search page
    When I select "publication" from "filter_name"
    And I follow "Add"
    And I select "publication 01" from "search_publication_id"
    And I press "Search"
    Then I should see "TRIAL"
    And I should see "u01@example.com"
    And I should not see "ACTIVE"
    And I should see "Showing 1 to 1 of 1 subscription(s)."

  @javascript
  Scenario: An admin searches with a publication with no subscription
    Given a publication: "p03" exists with name: "publication 03"
    And I am on admin subscription search page
    When I select "publication" from "filter_name"
    And I follow "Add"
    And I select "publication 03" from "search_publication_id"
    And I press "Search"
    Then I should see "No subscription found."

  Scenario: An admin searches with no filter
    Given I am on admin subscription search page
    When I press "Search"
    Then I should see "Showing 1 to 2 of 2 subscription(s)."
    And I should see "publication 01"
    And I should see "publication 02"


  @javascript
  Scenario: An admin searches by publication and result page's form contains publication field
    Given I am on admin subscription search page
    When I select "publication" from "filter_name"
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
      | Name    | Email           | ▲ Publication  | State  | Renewal    | Signed Up  |
      | f01 l01 | u01@example.com | publication 01 | TRIAL  | 04/12/2010 | 04/10/2010 |
      | f02 l02 | u02@example.com | publication 02 | ACTIVE | 04/12/2010 | 04/10/2010 |

  Scenario: An admin sorts search results by publication desc
    Given I am on admin subscription search page
    When I press "Search"
    And I follow "Publication"
    And I follow "▲ Publication"
    Then I should see the following "search_results" table:
      | Name    | Email           | ▼ Publication  | State  |
      | f02 l02 | u02@example.com | publication 02 | ACTIVE |
      | f01 l01 | u01@example.com | publication 01 | TRIAL  |

  @javascript
  Scenario: An admin searches for 22 results and result is paginated
    #XXX: per_page is hardcoded to be 20.  is it okay?
    Given 20 subscriptions exist with offer: offer "o01", user: user "u01", state: "TRIAL"
    And I am on admin subscription search page
    When I press "Search"
    Then I should see "Showing 1 to 20 of 22 subscription(s)."
    And I should see "« Previous 1 2 Next »"

