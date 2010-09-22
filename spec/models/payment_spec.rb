require 'spec_helper'

describe Payment do
  NUM = 1999119

  before(:each) do
    @payment = Payment.new # not active_record
    @payment.customer_id       = NUM
    @payment.first_name        = 'sender fname' 
    @payment.last_name         = 'sender lname'
    @payment.card_type         = 'visa'
    @payment.card_expires_on   = Date.today + 5
    @payment.card_number       = '4444333322221111'
    @payment.card_verification = '123'             
    @payment.money             = 200

    @payment.remove_recurrent_profile
  end

  # It is assumed that ActiveMerchant::Billing::CreditCard validation is fully tested
  it "should create a successful recurrent profile setup given valid credit_card, price and customer Id" do
    res = @payment.create_recurrent_profile
    res.success?.should be_true
  end

  it "should successfully trigger recurrent given valid price and customer Id" do
    # setup profile so that customer is valid
    res = @payment.create_recurrent_profile
    res.success?.should be_true

    res = @payment.call_recurrent_profile
    res.success?.should be_true
  end

  it "should successfully trigger recurrent with new price given valid customer Id with different price from the setup profile" do
    @payment.money = 100
    # setup profile so that customer is valid
    res = @payment.create_recurrent_profile
    res.success?.should be_true
    res.params["amount"].should == '10000'

    @payment.money = 30
    res = @payment.call_recurrent_profile
    res.success?.should be_true
    res.params["amount"].should == '3000'

    @payment.money = 45
    res = @payment.call_recurrent_profile
    res.success?.should be_true
    res.params["amount"].should == '4500'
  end

  it "should fail to trigger a recurrent given non-existing customer Id -- for a customer that has no recurrent profile" do
    # res = @payment.create_recurrent_profile
    res = @payment.call_recurrent_profile
    res.success?.should be_false
  end

  it "should fail to trigger a recurrent given no customer Id" do
    # setup profile so that customer is valid
    res = @payment.create_recurrent_profile
    res.success?.should be_true

    @payment.customer_id       = nil
    res = @payment.call_recurrent_profile
    res.success?.should be_false
  end

  it "should fail to trigger a recurrent given no price" do
    @payment.money             = nil
  end
  
  it "should successfully cancel recurrent given valid customer Id" do
    # setup profile so that customer is valid
    res = @payment.create_recurrent_profile
    res.success?.should be_true

    res = @payment.remove_recurrent_profile
    res.success?.should be_true
  end

  it "should cancel a recurrent given non-existing customer Id -- for a customer that has no recurrent profile" do
    res = @payment.remove_recurrent_profile
    res.success?.should be_true
  end
end
