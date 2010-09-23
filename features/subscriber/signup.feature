Feature: User registration
  In order to become a user on the Crikey site
  As a member of the public
  I want to be able to choose a subscription

  
@pending
  Scenario: A user can view the subscription page
    Given I am on the signup page
     When I follow "Register"
     Then I should see "Subscribe to Crikey"
      And I should see "Step 1"
      And I should see "Publication Name"
      And I should see "Subscription"
      And I should see "Offer 1"
      And I should see "Cost"
      And I should see "Choose a Free Gift!"
      And I should see "A free gift"
      And I should see "Next"
      And I should see "Cancel"
      And I should see "Other Ways to Subscribe"
      And I should see "Phone"
      And I should see "Fax"
      And I should see "Mail"
  
@pending
  Scenario: A user can complete "step 1" of the subscription form 
    Given I am on "step 1" of the subscription page
      And I check "Offer 1"
      And I check "Free gift 1"
     When I follow "Next"
      Then I should see "Subscribe to Crikey"
      And I should see "step 2"
      And I should see "Your Details"
      And I should see "I already have an account with Crikey"
      And I should see "This is my first subscription"
      And I should see "Username"
      And I should see "Password"
      And I should see "Next"
      And I should see "Cancel"

@pending
  Scenario: A new user can complete "step 2" of the subscription form 
    Given I am on "step 2" of the subscription page
    And I check "This is my first subscription"
    And I fill in "Username:" with "usera"
    And I fill in "Password:" with "crikey"
    And I follow "Next"
   Then I should see "Subscribe to Crikey"
    And I should see "step 2"
    And I should see "Your Details"
    And I should see "Please Enter Your Details"
    And I should see "Title"
    And I should see "First Name*"
    And I should see "last Name*"
    And I should see "How did you hear about Crikey?:*"
    And I should see "Email Address:*"
    And I should see "This is the email Crikey will send to"
    And I should see "Email Confirmation:*"
    And I should see "Phone Number:*"
    And I should see "If there are problems with email delivery this is how we contact you"
    And I should see "Street Address line 1:*"
    And I should see "Street Address line 2:"
    And I should see "City, State, Post Code:*"
    And I should see "Country:*"
    And I should see "Next"
    And I should see "Cancel"

@pending
  Scenario: A new user can complete the next phase of "step 2" in the subscription form 
    Given I am on "step 2" of the subscription page
    And I select "Mr" from "Title"
    And I fill in "First Name:*" with "firstname"
    And I fill in "Last Name:*" with "lastname"
    And I select "The Internet" from "How did you hear about Crikey?:*"
    And I fill in "Email Address:*" with "username@crikey.com"
    And I fill in "Email Confirmation:*" with "username@crikey.com"
    And I fill in "Phone Number:*" with "1234 094 035"
    And I fill in "Street Address line 1:*" with "Address A"
    And I fill in "Street Address line 2:" with "Address B"	
    And I fill in "City" with "Sydney"
    And I select "N.S.W" from "State"
    And I fill in "Post Code:*" with "2000"
    And I select "Montecarlo" from "Country"
    When I follow "Next"
   Then I should see "Subscribe to Crikey"
    And I should see "step 3"
    And I should see "Payment"
    And I should see "Credit Card"
    And I should see "Direct Debit"
    And I should see "Cheque"
    And I should see "Credit Card Details"
    And I should see "Card Type:"
    And I should see "Name on Card:*"
    And I should see "Field Label:"
    And I should see "e.g. 000012345677675"
    And I should see "Expiry Date"
    And I should see "e.g.06/11"
    And I should see "Finish"

@pending
  Scenario: An exsisting user can complete "step 2" of the subscription form 
    Given I am on "step 2" of the subscription page
    And I check "I already have an account with Crikey"
    And I fill in "Username:" with "userb"
    And I fill in "Password:" with "dikey"
    And I follow "Next"
   Then I should see "Subscribe to Crikey"
    And I should see "step 3"

@pending
Scenario: A user fails to fill in a required form
  Given I am on "step 2" of the subscription page
    Given I am on "step 2" of the subscription page
    And I select "Mr" from "Title"
    And I fill in "First Name:*" with "firstname"
    And I fill in "Last Name:*" with "lastname"
    And I select "The Internet" from "How did you hear about Crikey?:*"
    And I fill in "Email Address:*" with "username@crikey.com"
    And I fill in "Email Confirmation:*" with "username@crikey.com"
    And I fill in "Phone Number:*" with "1234 094 035"
    And I fill in "Street Address line 1:*" with "Address A"
    And I fill in "Street Address line 2:" with "Address B"	
    And I fill in "City" with "Sydney"
    And I select "N.S.W" from "State"
    And I fill in "Post Code:*" with "2000"
    And I select "Montecarlo" from "Country"
    When I follow "Next"
   Then I should be on "step 2" of the subscription page 
   And I should see "There were errorswith the form"
   And I should see "Phone number is required"
    
