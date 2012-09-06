Feature: An admin can view a subscriber's payment history
  In order to inspect a subscriber's payments
  As an admin
  I want to view a subscriber's payment history
  
  Background:
    Given an admin: "Homer" exists
      And a subscriber "Marge" exists with firstname: "Marge", lastname: "Simpson", email: "marge@springfield.com"
      And a publication "Publication A" exists with name: "Publication A"
      And a publication "Publication B" exists with name: "Publication B"
      And a subscription "The First Sub" exists with user: subscriber "Marge", publication: publication "Publication A"
      And a subscription "The Second Sub" exists with user: subscriber "Marge", publication: publication "Publication B"      
      And a direct debit payment exists with subscription: subscription "The First Sub", created_at: "2011-02-01", reference: "foo"
      And a payment exists with subscription: subscription "The Second Sub", created_at: "2011-01-01", card_expiry_date: "2013-01-01", first_name: "Myrtle", last_name: "Keebler"
      And a cheque payment exists with subscription: subscription "The First Sub", created_at: "2011-03-01"
     When I log in as admin "Homer"
      And I go to admin subscriber: "Marge"'s subscriber page
  
  Scenario: An admin can see the subscriber's email address
    Then I should see "Email address"
     And I should see "marge@springfield.com"
    
  Scenario: An admin can view a subscriber's payment history
     Then I should see the following "payment_history" table:
     | Payment Date           | Publication     | Cardholder Name     | Amount  | Card Number         | Expiry Date  | Payment Type | Reference |
     | 11:00 01/03/2011 EST   | Publication A   |                     | $1.00   |                     |              | Cheque       |                     |
     | 11:00 01/02/2011 EST   | Publication A   |                     | $1.00   |                     |              | Direct Debit | foo                 |
     | 11:00 01/01/2011 EST   | Publication B   | Myrtle Keebler      | $1.00   | XXXX-XXXX-XXXX-1111 | 01/13        | Credit Card  | Reference #12345678  |

  Scenario: An admin can sort a subscriber's payment history by date
     When I follow "Payment Date"
     Then I should see the following "payment_history" table:
     | Payment Date | Card Number         | Expiry Date | Payment Type |
     | 01/01/2011   | XXXX-XXXX-XXXX-1111 | 01/13       | Credit Card  |
     | 01/02/2011   |                     |             | Direct Debit |
     | 01/03/2011   |                     |             | Cheque       |
     When I follow "Payment Date"
     Then I should see the following "payment_history" table:
     | Payment Date | Card Number         | Expiry Date | Payment Type |
     | 01/03/2011   |                     |             | Cheque       |
     | 01/02/2011   |                     |             | Direct Debit |
     | 01/01/2011   | XXXX-XXXX-XXXX-1111 | 01/13       | Credit Card  |

  Scenario: An admin can sort a subscriber's payment history by date
     When I follow "Payment Type"
     Then I should see the following "payment_history" table:
     | Payment Date | Card Number         | Expiry Date | Payment Type |
     | 01/03/2011   |                     |             | Cheque       |
     | 01/01/2011   | XXXX-XXXX-XXXX-1111 | 01/13       | Credit Card  |
     | 01/02/2011   |                     |             | Direct Debit |
     When I follow "Payment Type"
     Then I should see the following "payment_history" table:
     | Payment Date | Card Number         | Expiry Date | Payment Type |
     | 01/02/2011   |                     |             | Direct Debit |
     | 01/01/2011   | XXXX-XXXX-XXXX-1111 | 01/13       | Credit Card  |
     | 01/03/2011   |                     |             | Cheque       |

  Scenario: An admin can sort a subscriber's payment history by publication
    When I follow "Publication"
    Then I should see the following "payment_history" table:
     | Payment Date           | Publication     | Cardholder Name     | Amount  | Card Number         | Expiry Date  | Payment Type | Reference |
     | 11:00 01/03/2011 EST   | Publication A   |                     | $1.00   |                     |              | Cheque       |                     |
     | 11:00 01/02/2011 EST   | Publication A   |                     | $1.00   |                     |              | Direct Debit | foo                 |
     | 11:00 01/01/2011 EST   | Publication B   | Myrtle Keebler      | $1.00   | XXXX-XXXX-XXXX-1111 | 01/13        | Credit Card  | Reference #12345678  |
    When I follow "Publication"
    Then I should see the following "payment_history" table:
     | Payment Date           | Publication     | Cardholder Name     | Amount  | Card Number         | Expiry Date  | Payment Type | Reference |
     | 11:00 01/01/2011 EST   | Publication B   | Myrtle Keebler      | $1.00   | XXXX-XXXX-XXXX-1111 | 01/13        | Credit Card  | Reference #12345678  |
     | 11:00 01/03/2011 EST   | Publication A   |                     | $1.00   |                     |              | Cheque       |                     |
     | 11:00 01/02/2011 EST   | Publication A   |                     | $1.00   |                     |              | Direct Debit | foo                 |




  Scenario: Payment history should be paginated
    Given 9 payments exist with subscription: subscription "The First Sub"
     When I go to admin subscriber: "Marge"'s subscriber page
     Then I should see "Displaying payments 1"
     Then I should see "10 of 12 in total"
     When I follow "Next"
     Then I should see "Displaying payments 11"
     Then I should see "12 of 12 in total"

  
