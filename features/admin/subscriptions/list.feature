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
      And a offer: "Offer 2" exists with name: "offer 2", publication: publication "Publication 2"
      And a subscription: "Subscription 1" exists with offer: offer "Offer 1", user: subscriber "Alice", id: 1
      And a subscription: "Subscription 2" exists with offer: offer "Offer 2", user: subscriber "Bob", id: 2
  	When I log in as admin "Alice"
	 # And I go to 
  	# When I log in as admin "Admin"

  @active
  Scenario: An admin can view all canceled subscriptions
    Given I am on admin canceled subscriptions search page
	Then I should see "Canceled Subscriptions"
		And I should see "Publication 1"
		And I should see "Publication 2"
