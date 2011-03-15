require 'spec_helper'

describe Payment do
  before(:each) do
    @offer = Factory(:offer)
    @offer_term = Factory.create(:offer_term, :months => 3, :offer_id => @offer.id)
    @subscription = Factory.stub(:subscription)
    @subscription.use_offer(@offer, @offer_term)
  end

  it "should be invalid with an invalid credit card" do
    payment = Factory.build(:payment, :card_number => '12345678900001234')
    payment.subscription = @subscription
    assert !payment.valid?
  end

  it "should be valid" do
    payment = Factory.build(:payment)
    payment.subscription = @subscription
    assert payment.valid?
  end



  describe "process a payment" do
    it "raise an exception on fail" do
      message = "Insufficient Funds"
      response = stub(:success? => false, :message => message)
      GATEWAY.expects(:purchase).returns(response)
      payment = Factory.build(:payment)
      payment.subscription = @subscription
      assert payment.valid?
      lambda {
        payment.save
      }.should raise_exception(PaymentFailedException, message)
    end

    it "should not raise on success" do
      count = Payment.count
      response = stub(:success? => true)
      GATEWAY.expects(:purchase).returns(response)
      payment = Factory.build(:payment)
      payment.subscription = @subscription
      assert payment.valid?
      payment.save
      assert_equal Payment.count, count + 1
      assert_equal payment.card_number, "XXXX-XXXX-XXXX-1111"
    end

    it "should not save the full CC number even if we don't set the payment type" do
      count = Payment.count
      response = stub(:success? => true)
      GATEWAY.expects(:purchase).returns(response)
      payment = Factory.build(:payment, :payment_type => nil)
      payment.subscription = @subscription
      assert payment.valid?
      payment.save
      assert_equal Payment.count, count + 1
      assert_equal payment.card_number, "XXXX-XXXX-XXXX-1111"
    end

    it "should not attempt a CC payment if payment_type is not credit_card" do
      count = Payment.count
      GATEWAY.expects(:purchase).never
      payment = Factory.build(:direct_debit_payment)
      payment.subscription = @subscription
      assert payment.valid?
      payment.save!
      assert_equal Payment.count, count + 1
    end
  end

  describe "payment description" do
    it "should be correct for credit card" do
      @payment = Factory.create(:payment, :payment_type => 'credit_card', :reference => nil)
      @payment.description.should == '$100.00 by Credit card'
    end

    it "should be correct for credit card with reference" do
      @payment = Factory.create(:payment, :payment_type => 'credit_card', :reference => "1234")
      @payment.description.should == '$100.00 by Credit card (Ref: 1234)'
    end

    it "should be correct for direct debit" do
      @payment = Factory.create(:payment, :payment_type => 'direct_debit', :reference => nil)
      @payment.description.should == '$100.00 by Direct debit'
    end

    it "should be correct for cheque" do
      @payment = Factory.create(:payment, :payment_type => 'cheque', :reference => nil)
      @payment.description.should == '$100.00 by Cheque'
    end
  end
end
