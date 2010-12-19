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
  end
end
