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

  it "should raise if not valid and process! is called" do
    payment = Payment.new
    lambda {
      payment.process!
    }.should raise_exception
  end

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

    it "should set processed_at on save" do
      Timecop.freeze(Time.now) do
        payment = Factory.build(:payment)
        payment.expects(:save!)
        payment.process!
        payment.processed_at.should == Time.now
      end
    end

    it "should set the reference to the secure pay order id" do
      Payment.any_instance.stubs(:generate_unique_id).returns('1234')
      payment = Factory.build(:payment, :payment_type => 'credit_card')
      payment.process!
      payment.reference.should == '1234'
    end
  end

  describe "of type token when processed" do
    before(:each) do
      @response_stub = stub(:success? => true, :params => { 'ponum' => '1234' }) 
    end

    it "should raise an exception if no token provided" do
      payment = Factory.build(:payment, :payment_type => :token)
      lambda {
        payment.process!
      }.should raise_error(Exceptions::PaymentTokenMissing)
    end

    it "should succeed when token provided and funds available" do
      GATEWAY.expects(:trigger_recurrent).with(10000, "123456").returns(@response_stub)
      payment = Factory.build(:payment, :payment_type => :token, :amount => 100)
      expect {
        payment.process!(:token => "123456")
      }.to change { Payment.count }.by(1)     
    end

    it "should allow the payment to be processed even if the payment has been saved" do
      GATEWAY.expects(:trigger_recurrent).with(10000, "123456").returns(@response_stub)
      payment = Factory.create(:token_payment)
      payment.process!(:token => "123456")
    end

    it "should not allow the payment to be processed once processed_at has been set" do
      payment = Factory.create(:token_payment, :processed_at => Time.now)
      lambda {
        payment.process!(:token => "123456")
      }.should raise_exception(Exceptions::PaymentAlreadyProcessed)
    end

    it "should set the reference" do
      GATEWAY.expects(:trigger_recurrent).with(10000, "123456").returns(@response_stub)
      payment = Factory.create(:token_payment)
      payment.process!(:token => "123456")
      payment.reference.should == '1234'
    end
  end

  describe "of type direct debit" do
    it "should not attempt a CC payment if payment_type is not credit_card" do
      count = Payment.count
      GATEWAY.expects(:purchase).never
      payment = Factory.build(:direct_debit_payment)
      payment.save!
      assert_equal Payment.count, count + 1
    end

    it "should be valid even of no CC details have been provided" do
      payment = Factory.build(:direct_debit_payment)
      payment.valid?.should be(true)
    end

    it "should set the reference" do
      payment = Factory.create(:direct_debit_payment, :reference => '123456')
      payment.reference.should == '123456'
    end
  end

  describe "of type historical" do
    it "should allow creation without token or card" do
      lambda {
        Payment.create!(:payment_type => :historical, :processed_at => Time.now, :reference => '1234', :amount => 10)
      }.should_not raise_error
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

  describe "full name" do
    it "should set firstname and lastname if provided" do
      payment = Factory.build(:payment, :full_name => "Daniel Draper")
      payment.save!
      payment.first_name.should == 'Daniel'
      payment.last_name.should == 'Draper'
    end

    it "should not change firstname and lastname if left blank" do
      attrs = Factory.attributes_for(:payment)
      payment = Payment.new(attrs)
      payment.save!
      payment.first_name.should == attrs[:first_name]
      payment.last_name.should == attrs[:last_name]
    end

    it "should not be valid if only a firstname is provided in the full_name field" do
      payment = Factory.build(:payment, :full_name => "Daniel")
      payment.valid?.should be(false)
    end

    it "should give custom errors if name is not provided" do
      payment = Payment.new
      payment.valid?.should be(false)
      payment.errors[:first_name].should == 'on the credit card needs to be provided'
      payment.errors[:last_name].should == 'on the credit card needs to be provided'
    end

    it "should handle a middle initial" do
      payment = Factory.build(:payment, :full_name => "Daniel J Draper")
      payment.save!
      payment.first_name.should == 'Daniel'
      payment.last_name.should == 'J Draper'
    end
  end
end
