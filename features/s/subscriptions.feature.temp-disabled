Feature: A subscriber can view subscriptions
  As a subscriber who is a new user or has never paid for subscriptions using their Credit Card details
  I want to be able to log in and view my subscriptions and pay for them using my Credit Card details or Direct Debit

  Background:
    Given a subscriber: "Bart" exists
      And a publication: "Publication 1" exists with name: "Publication 1"
      And a publication: "Publication 2" exists with name: "Publication 2"
      And a offer: "Offer 1" exists with name: "offer 1", publication: publication "Publication 1"
      And a offer: "Offer 2" exists with name: "offer 2", publication: publication "Publication 2"
      And a subscription: "Subscription 1" exists with offer: offer "Offer 1", user: subscriber "Bart", id: 1
      And a subscription: "Subscription 2" exists with offer: offer "Offer 2", user: subscriber "Bart", id: 2, state: "trial"
  	When I log in as subscriber "Bart"

  Scenario: An subscriber can view their subscriptions
  	Given I am on the s subscriptions page
  	Then I should see "My Subscriptions"
    	And I should see "Publication 1"
    	And I should see "Publication 2"
	   	And I should see "Pay" within "tr[@class=' odd ']"
	   	And I should see "Pay" within "tr[@class=' even last']"
		
  Scenario: A new subscriber can select to payment method to pay for a subscription
	Given I am on the s subscriptions page
	When I follow "Pay" within "tr[@class=' even last']"
	Then I should see "Paying For Subscription: Publication 2" within "h2"
		And I should see "Please choose your method of payment" within "p"
		And I should see "Credit Card"
		And I should see "Direct Debit"

  Scenario: A new subscriber can pay for a subscription by Credit Card
	Given I am on the s subscription payment page for 2  # 2 is the id of 'Subscription 2'
	When I choose "payment_method_new_credit_card"
	# Then I should be on the s subscription payment page for 2 # the same page
		Then I should see "Card number"
		# And I should see "Card type"
		And I should see "Card verification"
		And I should see "Card expires on"
		And I should see "First name"
		And I should see "Last name"
		# And I should see "Submit"
	When I select "Visa" from "payment[card_type]"
		And I fill in "payment[card_number]" with "4444333322221111"
		And I fill in "payment[card_verification]" with "111"
		And I select "2019" from "payment[card_expires_on(1i)]"
		And I select "12" from "payment[card_expires_on(2i)]"
		And I fill in "payment[first_name]" with "Bart"
		And I fill in "payment[last_name]" with "Miller"
		And I press "Submit"
	Then I should be on the s subscriptions page
		And I should see "Congratulations! Your subscription was successful using your new Credit Card details." within "span[@style='color: green']"

  @allow-rescue
  Scenario: A new subscriber will see an error if she doesn't fill in all credit card details
	Given I am on the s subscription payment page for 2  # 2 is the id of 'Subscription 2'
	When I choose "payment_method_new_credit_card"
		And I select "Visa" from "payment[card_type]"
		And I fill in "payment[card_number]" with ""
		And I fill in "payment[card_verification]" with "111"
		And I select "2019" from "payment[card_expires_on(1i)]"
		And I select "12" from "payment[card_expires_on(2i)]"
		And I fill in "payment[first_name]" with "Bart"
		And I fill in "payment[last_name]" with "Miller"
		And I press "Submit"
	Then I should be on the s subscriptions page
		And I should see "You do not have any profile in Secure Pay. Please fill in your new Credit Card details." within "span[@style='color: red']"

  Scenario: A new subscriber can pay for a subscription by Direct Debit
	Given I am on the s subscription payment page for 2  # 2 is the id of 'Subscription 2'
	When I choose "payment_method_direct_debit"
	Then I should see "By clicking on Finish, you will be forwarded to the direct debit page where you can get all the information you need on how to proceed with your payment."
	When I press "Submit"
	Then I should be on the s subscription direct debit page for 2
	And I should see "Bank Account - direct debit request(PDF)"
	And I should see "Credit Card - direct debit request(PDF)"

  @active
  Scenario: A subscriber can cancel a trial subscription
	Given I am on the s subscriptions page
	When I follow "Cancel" within "tr[@class=' even last']"
	# Then I should see a confirmation message
	# Then I should see a "Are you sure you want to cancel Publication 2 ?" confirm dialog
	# When I press "ok" => do cancelation, when i press "cancel" => stay on the same page!!!
	Then I should be on the s subscriptions page
		And I should see "You have successfully canceled your subscription."
		And I should see "squatter" within "tr[@class=' even last']"
