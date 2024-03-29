Feature: Suspend a subscription
  In order to suspend extend a user's subscription period
  As an admin
  I want to temporarily suspend a user's subscription

  Background:
    Given an admin: "Homer" exists
      And the date is "2011-01-1 12:00pm"
      And a publication: "p01" exists with name: "publication 01"
      And a publication: "p02" exists with name: "publication 02"
      And an offer: "o01" exists with publication: publication "p01"
      And an offer: "o02" exists with publication: publication "p02"
      And a user: "u01" exists with firstname: "f01", lastname: "l01", email: "u01@example.com", email_confirmation: "u01@example.com"
      And a user: "u02" exists with firstname: "f02", lastname: "l02", email: "u02@example.com", email_confirmation: "u02@example.com"
      And a subscription: "sub1" exists with publication: publication "p01", user: user "u01", state: "active"
      And a subscription: "sub2" exists with publication: publication "p02", user: user "u02", state: "suspended"
      And subscription "sub1" expires in "30" days
      And subscription "sub2" expires in "61" days
      And subscription "sub2"'s current state expires in "30" days
     When I log in as admin "Homer"
  
  @javascript
  Scenario: An admin can suspend a subscription
     When I go to admin subscription search page
      And I press "Search"
     Then I should see the following table rows in any order:
     | Name    | State     | Renewal Due |
     | f01 l01 | active    | 31/01/2011  |
     | f02 l02 | suspended | 3/03/2011   |

     When I follow "Suspend"
      And I fill in "Number of days to suspend subscription" with "31"
      And I press "Suspend"
     Then I should see "Subscription to publication 01 for f01 l01 suspended for 31 days"
      And I should be on admin subscription search page
      And I should not see "active"

      And I should see the following table rows:
      | Name    | State     | Renewal Due |
      | f02 l02 | suspended | 3/03/2011   |
      | f01 l01 | suspended | 3/03/2011   |

  @javascript @wip
  Scenario: An admin can schedule a suspension in the future
     When I go to admin subscription search page
      And I press "Search"
     Then I should see the following table rows in any order:
     | Name    | State     | Renewal Due |
     | f01 l01 | active    | 31/01/2011  |
     | f02 l02 | suspended | 3/03/2011   |

     When I follow "Suspend"
      And I select "2011-01-10" as the "Start date" date
      And I fill in "Number of days to suspend subscription" with "31"
      And I press "Suspend"
     Then I should see "Subscription to publication 01 for f01 l01 will be suspended for 31 days starting on 10/01/2011"
      And I should be on admin subscription search page
      And I should see the following table rows in any order:
      | Name    | State     | Renewal Due |
      | f01 l01 | active    | 31/01/2011  |
      | f02 l02 | suspended | 3/03/2011   |

     When the date is "2011-01-10"
      And I go to admin subscription search page
      And I press "Search"

     Then I should see the following table rows:
     | Name    | State     | Renewal Due  |
     | f02 l02 | suspended | 3/03/2011    |
     | f01 l01 | suspended | 13/03/2011   |

  @javascript
  Scenario: An admin cannot suspend an already suspended subscription
     When I go to admin subscription search page
      And I press "Search"
    Given subscription "sub1" is suspended for "31" days
     When I follow "Suspend"
      And I fill in "Number of days to suspend subscription" with "31"
      And I press "Suspend"
     Then I should see "Subscription to publication 01 for f01 l01 is already suspended!"

  Scenario: An admin cannot suspend a subscription without an expiry date
    Given subscription "sub1" has no expiry date
     When I go to admin subscription search page
     Then I should not see "Suspend" within "a"

  @javascript
  Scenario: An admin can un-suspend a subscription
     When I go to admin subscription search page 
      And I press "Search"
      And I follow "Unsuspend"
     Then I should see "Subscription to publication 02 for f02 l02 is now active"
      And I should be on admin subscription search page
     When I press "Search"
     Then I should not see "suspended"
      And I should see the following table rows in any order:
      | Name    | State  | Renewal Due |
      | f01 l01 | active | 31/01/2011  |
      | f02 l02 | active | 01/02/2011  |

  @javascript
  Scenario: An admin cannot un-suspend an already unsuspended subscription
     When I go to admin subscription search page
      And I press "Search"
    Given subscription "sub2" is unsuspended
     When I follow "Unsuspend"
     Then I should see "Subscription to publication 02 for f02 l02 is already active!"
  
  @javascript
  Scenario: An admin can cancel a scheduled suspension
     When I go to admin subscription search page
      And I press "Search"
     Then I should see the following table rows in any order:
      | Name    | State     | Renewal Due |
      | f01 l01 | active    | 31/01/2011  |
      | f02 l02 | suspended | 3/03/2011   |
  
     When I follow "Suspend"
      And I select "2011-01-10" as the "Start date" date
      And I fill in "Number of days to suspend subscription" with "31"
      And I press "Suspend"
     When I follow "Scheduled suspensions"
      And I follow "Cancel"
      And I confirm the javascript alert
     Then I should see "Scheduled suspension to publication 01 for f01 l01 has been cancelled."
  
  
  
