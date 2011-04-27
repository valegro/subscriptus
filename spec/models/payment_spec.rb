require 'spec_helper'

describe Payment do
  it "should be invalid with an invalid credit card" do
    payment = Factory.build(:payment, :card_number => '12345678900001234')
    assert !payment.valid?
  end

  it "should be valid" do
    payment = Factory.build(:payment)
    assert payment.valid?
  end

  it "should raise if not valid and process! is called"

  describe "of type credit_card when processed" do
    it "raise an exception on fail" do
      message = "Insufficient Funds"
      response = stub(:success? => false, :message => message)
      GATEWAY.expects(:purchase).returns(response)
      payment = Factory.build(:payment)
      assert payment.valid?
      lambda {
        payment.process!
      }.should raise_exception(Exceptions::PaymentFailedException, message)
    end

    it "should not raise on success" do
      response = stub(:success? => true)
      GATEWAY.expects(:purchase).returns(response)
      payment = Factory.build(:payment)
      assert payment.valid?
      expect {
        payment.process!
      }.to change { Payment.count }.by(1)
      payment.card_number.should =="XXXX-XXXX-XXXX-1111"
    end

    it "should not save the full CC number even if we don't set the payment type" do
      response = stub(:success? => true)
      GATEWAY.expects(:purchase).returns(response)
      payment = Factory.build(:payment, :payment_type => nil)
      assert payment.valid?
      expect {
        payment.process!
      }.to change { Payment.count }.by(1)
      payment.card_number.should == "XXXX-XXXX-XXXX-1111"
    end

    it "should not allow processing once the payment has been saved" do
      payment = Factory.create(:payment, :processed_at => Time.now)
      lambda {
        payment.process!
      }.should raise_error(Exceptions::PaymentAlreadyProcessed)
    end

    it "should set the payment description" do
      payment = Factory.create(:payment, :payment_type => 'credit_card', :reference => nil)
      payment.description.should == '$100.00 by Credit card'
    end

    it "should set the payment description with a reference" do
      payment = Factory.create(:payment, :payment_type => 'credit_card', :reference => "1234")
      payment.description.should == '$100.00 by Credit card (Ref: 1234)'
    end

    it "should save the record" do
      payment = Factory.build(:payment)
      payment.expects(:save!)
      payment.process!
    end

    it "should set processed_at on save"
  end

  describe "of type token when processed" do
    it "should raise an exception if no token provided" do
      payment = Factory.build(:payment, :payment_type => :token)
      lambda {
        payment.process!
      }.should raise_error(Exceptions::PaymentTokenMissing)
    end

    it "should succeed when token provided and funds available" do
      response = stub(:success? => true)
      GATEWAY.expects(:trigger_recurrent).with(10000, "123456").returns(response)
      payment = Factory.build(:payment, :payment_type => :token, :amount => 100)
      expect {
        payment.process!(:token => "123456")
      }.to change { Payment.count }.by(1)     
    end

    it "should allow the payment to be processed even if the payment has been saved"
    it "should not allow the payment to be processed once processed_at has been set"
  end

  describe "of type direct debit" do
    it "should not attempt a CC payment if payment_type is not credit_card" do
      count = Payment.count
      GATEWAY.expects(:purchase).never
      payment = Factory.build(:direct_debit_payment)
      assert payment.valid?
      payment.save!
      assert_equal Payment.count, count + 1
    end
  end

  describe "payment description" do
    it "should be correct for direct debit" do
      @payment = Factory.create(:payment, :payment_type => 'direct_debit', :reference => nil)
      @payment.description.should == '$100.00 by Direct debit'
    end

    it "should be correct for cheque" do
      @payment = Factory.create(:payment, :payment_type => 'cheque', :reference => nil)
      @payment.description.should == '$100.00 by Cheque'
    end
  end

  describe "token saved to the gateway" do
    it "should return success" do
      @payment = Factory.build(:payment)
      response = stub(:success? => true)
      GATEWAY.expects(:setup_recurrent) #.with(0, ActiveMerchant::Billing::CreditCard.any_instance, '12345').returns(response)
      @payment.store_card_on_gateway('12345')
    end
  end
end
