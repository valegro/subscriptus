=begin
  Author: Subscriptus Support
  Email: support@subscriptus.com.au
  Description: This module uses SecurePeriodic which is an application that allows real time processing of recurring credit card or direct entry payments on specified dates that suit merchant requirements.
  URL: http://www.securepay.com.au/resources/Secure-XML-API/Integration-Guide-Periodic-and-Triggered-add-in-pg02.html#11
=end

require 'test_helper'

class RemoteSecurePayAuExtendedTest < Test::Unit::TestCase
  
  def setup
    @gateway = SecurePayAuExtendedGateway.new(fixtures(:secure_pay_au_extended))
    
    @amount = 100
    @credit_card = credit_card('4444333322221111')

    @purchase_options = { 
      :order_id => '1',
      :billing_address => address,
      :description => 'Store Purchase'
    }

    @recurrent_options = { 
      :customer => "i_am_20_length_valid"  # should be a unique 1...20 characters with no space
    }

    @gateway.cancel_recurrent(@recurrent_options) # to avoid Client with duplicate id gateway error
  end

  # SecurePayAu Gateway does not check for credit card validation

  def test_invalid_login
    gateway = SecurePayAuExtendedGateway.new(
                :login => '',
                :password => ''
              )
    assert response = gateway.purchase(@amount, @credit_card, @purchase_options)
    assert_failure response
    assert_equal "Invalid merchant ID", response.message
  end

  # ------------------ ActiveMerchant Purchase tests ----------------------- #
  def test_successful_purchase
    assert response = @gateway.purchase(@amount, @credit_card, @purchase_options)
    assert_success response
    assert_equal 'Approved', response.message
  end

  def test_unsuccessful_purchase
    assert response = @gateway.purchase(@amount, @credit_card, {})
    assert_equal response.success?, false
    assert_failure response
    assert_equal "Message format error.  Mandatory field [purchaseOrderNo] is missing\n", response.message
  end

  # ------------------ Recurrent tests ----------------------- #
  def test_successful_recurrent
    assert response = @gateway.setup_recurrent(@amount, @credit_card, @recurrent_options)
    assert_success response
    assert_equal 'Successful', response.message
    assert response = @gateway.trigger_recurrent(nil, @recurrent_options) # the same amount
    assert_success response
    assert_equal 'Approved', response.message
  end

  def test_unsuccessful_setup_recurrent_invalid_client_id
    # no Client ID (customer)
    assert response = @gateway.setup_recurrent(@amount, @credit_card, {})
    assert_failure response
    assert_equal 'No Client ID provided', response.message
    # Client ID  (customer) contains more than 20 characters
    assert response = @gateway.setup_recurrent(@amount, @credit_card, {:customer => "iammorethantwentycharacterlong"})
    assert_failure response
    assert_equal 'Invalid Client ID', response.message
    # Client ID  (customer) contains space
    assert response = @gateway.setup_recurrent(@amount, @credit_card, {:customer => "ihave space"})
    assert_failure response
    assert_equal 'Invalid Client ID', response.message
  end

  def test_unsuccessful_setup_recurrent_invalid_amount
    # no amount
    assert response = @gateway.setup_recurrent(nil, @credit_card, @recurrent_options)
    assert_failure response
    assert_equal 'No Amount Specified', response.message
    # string amount
    assert response = @gateway.setup_recurrent("invalid", @credit_card, @recurrent_options)
    assert_failure response
    assert_equal 'No Amount Specified', response.message
  end

  def test_unsuccessful_setup_recurrent_invalid_credit_card
    # expired date
    @credit_card.year = '2005'
    assert response = @gateway.setup_recurrent(@amount, @credit_card, @recurrent_options)
    assert_failure response
    assert_equal 'Invalid Credit Card', response.message
    # inalid type
    @credit_card.type = 'invalidCardType'
    assert response = @gateway.setup_recurrent(@amount, @credit_card, @recurrent_options)
    assert_failure response
    assert_equal 'Invalid Credit Card', response.message
  end

  def test_failure_try_to_trigger_unsetup_recurrent
    assert response = @gateway.trigger_recurrent(@amount, @recurrent_options) # new amount
    assert_failure response
    assert_equal 'Payment not found', response.message
  end

  def test_success_trigger_with_nil_amount
    assert response = @gateway.setup_recurrent(@amount, @credit_card, @recurrent_options)
    assert_success response
    assert response = @gateway.trigger_recurrent(nil, @recurrent_options) # the same amount
    assert_success response
    assert_equal @amount.to_s, response.params["amount"] # amount should be the same as setup time
  end

  def test_success_trigger_with_various_amounts
    @amount = 500
    assert response = @gateway.setup_recurrent(@amount, @credit_card, @recurrent_options)
    assert_success response
    @amount = 300
    assert response = @gateway.trigger_recurrent(@amount, @recurrent_options) # the same amount
    assert_success response
    assert_equal "300", response.params["amount"] # amount should be the same as setup time
  end

  def test_unsuccessful_trigger_recurrent_invalid_client_id
    # no Client ID (customer)
    assert response = @gateway.trigger_recurrent(@amount, {})
    assert_failure response
    assert_equal 'No Client ID provided', response.message
    # Client ID  (customer) contains more than 20 characters
    assert response = @gateway.trigger_recurrent(@amount, {:customer => "iammorethantwentycharacterlong"})
    assert_failure response
    assert_equal 'Invalid Client ID', response.message
    # Client ID  (customer) contains space
    assert response = @gateway.trigger_recurrent(@amount, {:customer => "ihave space"})
    assert_failure response
    assert_equal 'Invalid Client ID', response.message
  end
  
  def test_success_cancel_unsetup_recurrent
    assert response = @gateway.cancel_recurrent(@recurrent_options)
    assert_success response
  end

  def test_unsuccessful_can_recurrent_invalid_client_id
    # no Client ID (customer)
    assert response = @gateway.cancel_recurrent({})
    assert_failure response
    assert_equal 'No Client ID provided', response.message
    # Client ID  (customer) contains more than 20 characters
    assert response = @gateway.cancel_recurrent({:customer => "iammorethantwentycharacterlong"})
    assert_failure response
    assert_equal 'Invalid Client ID', response.message
    # Client ID  (customer) contains space
    assert response = @gateway.cancel_recurrent({:customer => "ihave space"})
    assert_failure response
    assert_equal 'Invalid Client ID', response.message
  end
end
