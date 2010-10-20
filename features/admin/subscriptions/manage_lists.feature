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
      And a offer: "Offer 1" exists with name: "offer 1", publication: publication "Publication 1"
      And a offer: "Offer 2" exists with name: "offer 2", publication: publication "Publication 2", id: 12
      And a subscription: "Subscription 1" exists with offer: offer "Offer 1", user: subscriber "Alice", id: 1
      And a subscription: "Subscription 2" exists with offer: offer "Offer 2", user: subscriber "Bob", id: 2
	  And do transition to state "canceled" for subscription: "Subscription 2" existing with id: 2
	When I log in as admin "Admin"

  Scenario: An admin can view all canceled subscriptions
    Given I am on admin canceled subscriptions page
	Then I should see "Canceled Subscriptions"
		And I should see "Publication 2"
		And I should not see "Publication 1"

  @active
  Scenario: An Admin can mark a cancelled subscription as processed
	Given I am on admin canceled subscriptions page
	Then I should see "canceled" within "tr[@class=' odd last']"
	When I follow "Mark as Processed" within "tr[@class=' odd last']"
	Then I should not see "canceled"
