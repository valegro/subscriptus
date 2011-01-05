Feature: Subscription List
  In order to CRUD subscriptions
  As an admin
  I want to be able to view different types of subscriptions

  Background:
    Given an admin: "Admin" exists
      And a subscriber: "Bob" exists
      And a subscriber: "Alice" exists
      And a publication: "Publication 1" exists with name: "Publication 1"
      And a publication: "Publication 2" exists with name: "Publication 2"
      And a publication: "Publication 3" exists with name: "Publication 3"
      And a offer: "Offer 1" exists with name: "offer 1", publication: publication "Publication 1"
      And a offer: "Offer 2" exists with name: "offer 2", publication: publication "Publication 2", id: 12
      And a subscription: "Subscription 1" exists with publication: publication "Publication 1", user: subscriber "Alice", id: 1
      And a subscription: "Subscription 2" exists with publication: publication "Publication 2", user: subscriber "Bob", id: 2
      And a subscription: "Pending Subscription" exists with publication: publication "Publication 3", user: subscriber "Bob", state: "pending"
	  And cancel subscription: "Subscription 2" existing with id: 2
	When I log in as admin "Admin"

  Scenario: An admin can view all cancelled subscriptions
    Given I am on admin cancelled subscriptions page
  	Then I should see "Cancelled Subscriptions"
		  And I should see "Publication 2"
		  And I should not see "Publication 1"

  @active
  Scenario: An Admin can mark a cancelled subscription as processed
	  Given I am on admin cancelled subscriptions page
	    Then I should see "cancelled" within "tr[@class=' odd last']"
	  When I follow "Mark processed" within "tr[@class=' odd last']"
	    Then I should not see "cancelled"
	    And I should see "You have successfully marked a subscription as processed. It now exists in Squattered subscriptions."

  @active
  Scenario: An Admin can view all pending subscriptions
    Given I am on the admin pending subscriptions page
  	Then I should see "Pending Subscriptions"
		  And I should see "Publication 3"
		  And I should see "Verify"
		  And I should see "Cancel"
		  And I should not see "Publication 1"


