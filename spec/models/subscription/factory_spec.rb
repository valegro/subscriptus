require 'spec_helper'

describe SubscriptionFactory do

  before(:each) do
    cm_return = stub(:success? => true)
    CM::Recipient.stubs(:find_all).returns(cm_return)
    CM::Recipient.stubs(:update)
    CM::Recipient.stubs(:create!)

    @offer = Factory.create(:offer)
    @term1 = Factory.create(:offer_term, :price => 100, :months => 1)
    @term2 = Factory.create(:offer_term, :price => 200, :months => 2)
    @offer.offer_terms << @term1
    @offer.offer_terms << @term2

    stub_wordpress

    @attributes = {
      'user_attributes' => Factory.attributes_for(:user),
      'payments_attributes' => { "0" => Factory.attributes_for(:payment) }
    }
  end

  it "should create a subscription with attributes" do
    @offer.gifts.add(@gift1)
    @offer.gifts.add(@gift2)
    expect {
      subscription = SubscriptionFactory.build(@offer, :attributes => @attributes)
      subscription.save!
    }.to change { Subscription.count }.by(1)
  end

  it "should create a subscription from an instance of a factory" do
    expect {
      factory = SubscriptionFactory.new(@offer, :attributes => @attributes)
      subscription = factory.build
      subscription.save!
    }.to change { Subscription.count }.by(1)
  end

  it "should create and set a subscription action" do
    t = Time.local(2011, 1, 1, 0, 0, 0)
    Timecop.freeze(t) do
      factory = SubscriptionFactory.new(@offer, :attributes => @attributes)
      subscription = factory.build
      subscription.actions.size.should == 1
      subscription.actions.first.offer_name.should == @offer.name
      subscription.actions.first.price.should == @offer.offer_terms.first.price
      subscription.actions.first.term_length.should == @offer.offer_terms.first.months
      subscription.actions.first.applied_at.should == t
      expect {
        subscription.save!
      }.to change { SubscriptionAction.count }.by(1)
    end
  end

  describe "offer basics" do
    it "should set term to first term if none set" do
      t = Time.local(2011, 1, 1, 0, 0, 0)
      Timecop.travel(t) do
        subscription = SubscriptionFactory.build(@offer)
        subscription.actions.last.price.should == @term1.price
        subscription.expires_at.should == Time.local(2011, 2, 1, 0, 0, 0).in_time_zone("UTC")
      end
    end

    it "should set accept a specific term" do
      t = Time.local(2011, 1, 1, 0, 0, 0)
      Timecop.travel(t) do
        subscription = SubscriptionFactory.build(@offer, :term_id => @term2.id)
        subscription.actions.last.price.should == @term2.price
        subscription.expires_at.should == Time.local(2011, 3, 1, 0, 0, 0).in_time_zone("UTC")
      end
    end

    it "should raise if provided an invalid term id" do
      t = Time.local(2011, 1, 1, 0, 0, 0)
      Timecop.travel(t) do
        lambda {
          SubscriptionFactory.build(@offer, :term_id => -1)
        }.should raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    it "should raise if the offer term does not match the offer" do
      @offer_term = Factory.create(:offer_term, :months => 3, :offer => Factory.create(:offer))
      lambda {
        SubscriptionFactory.build(@offer, :term_id => @offer_term.id)
      }.should raise_exception(Exceptions::InvalidOfferTerm)
    end

    it "should set the publication" do
      subscription = SubscriptionFactory.build(@offer)
      subscription.publication.should == @offer.publication
    end
  end

  describe "gifts" do
    before(:each) do
      @gift1 = Factory.create(:gift, :name => "Gift 1")
      @gift2 = Factory.create(:gift, :name => "Gift 2")
      @gift3 = Factory.create(:gift, :name => "Gift 3")
      @gift4 = Factory.create(:gift, :name => "Gift 4")
    end

    it "should have no gifts if none provided" do
      subscription = SubscriptionFactory.build(@offer)
      subscription.actions.last.gifts.empty?.should be(true)
    end

    it "should have the included gifts from the offer" do
      @offer.gifts.add(@gift1)
      @offer.gifts.add(@gift2)
      subscription = SubscriptionFactory.build(@offer, :attributes => @attributes)
      subscription.actions.last.gifts.size.should == 2
      expect {
        subscription.save!
      }.to change { subscription.orders.count }.by(1)
      subscription.reload
      subscription.orders.last.gifts.size.should == 2
    end

    it "should select just one optional gift from the offer" do
      @offer.gifts.add(@gift1, true)
      @offer.gifts.add(@gift2, true)
      subscription = SubscriptionFactory.build(@offer, :optional_gift => "#{@gift2.id}", :attributes => @attributes)
      subscription.actions.last.gifts.size.should == 1
      subscription.actions.last.gifts.first.name.should == 'Gift 2'
      expect {
        subscription.save!
      }.to change { subscription.orders.count }.by(1)
      subscription.reload
      subscription.orders.last.gifts.size.should == 1
    end

    it "should subscribe with no optional gifts if none was selected even though the offer had them" do
      @offer.gifts.add(@gift1, true)
      @offer.gifts.add(@gift2, true)
      subscription = SubscriptionFactory.build(@offer, :attributes => @attributes)
      subscription.actions.last.gifts.empty?.should be(true)
      expect {
        subscription.save!
      }.to_not change { subscription.orders.count }.by(1)
    end

    it "should raise if you select an optional gift that is not available on the offer" do
      @offer.gifts.add(@gift1, true)
      lambda {
        SubscriptionFactory.build(@offer, :optional_gift => @gift2.id)
      }.should raise_error(Exceptions::GiftNotAvailable, "The Gift #{@gift2.name} is no longer available")
    end

    it "should treat one optional gift as an included gift" do
      @offer.gifts.add(@gift1)
      @offer.gifts.add(@gift2, true)
      subscription = SubscriptionFactory.build(@offer, :attributes => @attributes)
      subscription.actions.last.gifts.size.should == 2
      expect {
        subscription.save!
      }.to change { subscription.orders.count }.by(1)
      subscription.reload
      subscription.orders.last.gifts.size.should == 2
    end

    it "should add included gifts and allow selection of an optional gift simultaneously" do
      @offer.gifts.add(@gift1)
      @offer.gifts.add(@gift2)
      @offer.gifts.add(@gift3, true)
      @offer.gifts.add(@gift4, true)
      subscription = SubscriptionFactory.build(@offer, :optional_gift => @gift4.id, :attributes => @attributes)
      subscription.actions.last.gifts.size.should == 3
      expect {
        subscription.save!
      }.to change { subscription.orders.count }.by(1)
      subscription.orders(true).last.gifts.size.should == 3 
    end

    it "should raise if an optional gift becomes unavailable" do
      @offer.gifts.add(@gift1, true)
      @offer.gifts.add(@gift2, true)
      @gift2.update_attributes(:on_hand => 0)
      lambda {
        SubscriptionFactory.build(@offer, :optional_gift => @gift2.id)
      }.should raise_error(Exceptions::GiftNotAvailable, "The Gift #{@gift2.name} is no longer available")
    end

    it "should accept a list of included gift ids as validation" do
      @offer.gifts.add(@gift1)
      @offer.gifts.add(@gift2)
      subscription = SubscriptionFactory.build(@offer, :included_gift_ids => [@gift1, @gift2].map(&:id), :attributes => @attributes)
      subscription.actions.last.gifts.size.should == 2
      expect {
        subscription.save!
      }.to change { subscription.orders.count }.by(1)
      subscription.orders(true).last.gifts.size.should == 2 
    end

    it "should raise if an included gift becomes unavailable" do
      @offer.gifts.add(@gift1)
      @offer.gifts.add(@gift2)
      @gift1.update_attributes(:on_hand => 0)
      lambda {
        SubscriptionFactory.build(@offer, :included_gift_ids => [@gift1, @gift2].map(&:id).map(&:to_s))
      }.should raise_error(Exceptions::GiftNotAvailable, "The Gift #{@gift1.name} is no longer available")
    end

    it "should raise if an included gift does not exist" do
      lambda {
        SubscriptionFactory.build(@offer, :included_gift_ids => [-1])
      }.should raise_error(Exceptions::GiftNotAvailable, "The Gift is no longer available")
    end

    it "should raise if an optional gift does not exist" do
      lambda {
        SubscriptionFactory.build(@offer, :optional_gift => -1)
      }.should raise_error(Exceptions::GiftNotAvailable, "The Gift is no longer available")
    end
  end

  describe "Initial State" do
    it "should set to active by default" do
      subscription = SubscriptionFactory.build(@offer)
      subscription.state.should == 'active'
    end

    it "should allow me to specify the initial state" do
      subscription = SubscriptionFactory.build(@offer, :init_state => 'trial')
      subscription.state.should == 'trial'
    end
  end

  describe "Source" do
    it "should set the source if provided" do
      source = Factory.create(:source)
      subscription = SubscriptionFactory.build(@offer, :source => source)
      subscription.source.name == source.name
    end
  end

  describe "a payment" do
    it "should be created when a subscription is created" do
      gw_response = stub(:success? => true)
      GATEWAY.expects(:purchase).returns(gw_response)
      factory = SubscriptionFactory.new(@offer, :attributes => @attributes)
      subscription = factory.build
      expect {
        subscription.save!
      }.to change { subscription.payments.count }.by(1)
      subscription.payments.last.amount.should == @term1.price
      subscription.payments.last.payment_type.should == :credit_card
      subscription.payments.last.card_number.should == "XXXX-XXXX-XXXX-#{@attributes['payments_attributes']['0'][:card_number][-4..-1]}"
    end

    it "should not be created when a subscription is created if gateway authorization fails" do
      gw_response = stub(:success? => false, :message => "Test Failure")
      GATEWAY.expects(:purchase).returns(gw_response)
      factory = SubscriptionFactory.new(@offer, :attributes => @attributes)
      subscription = factory.build
      expect {
        lambda {
          subscription.save!
        }.should raise_exception(Exceptions::PaymentFailedException)
      }.to change { subscription.payments.count }.by(0)
    end
  end

  describe "Concession" do
    after(:each) do
      expect {
        @subscription.save!
      }.to change { @subscription.payments.count }.by(1)
    end

    it "should set state to pending" do
      gw_response = stub(:success? => true)
      GATEWAY.expects(:purchase).returns(gw_response)
      factory = SubscriptionFactory.new(@offer, :attributes => @attributes, :concession => :student)
      @subscription = factory.build
      @subscription.state.should == 'pending'
    end

    it "should set the pending value for student" do
      factory = SubscriptionFactory.new(@offer, :attributes => @attributes, :concession => :student)
      @subscription = factory.build
      @subscription.pending.should == :student_verification
    end

    it "should set the pending value for concession" do
      factory = SubscriptionFactory.new(@offer, :attributes => @attributes, :concession => :concession)
      @subscription = factory.build
      @subscription.pending.should == :concession_verification
    end

    it "should not set the expiry date" do
      factory = SubscriptionFactory.new(@offer, :attributes => @attributes, :concession => :concession)
      @subscription = factory.build
      @subscription.expires_at.should == nil
    end

    it "should set the action to be applied" do
      factory = SubscriptionFactory.new(@offer, :attributes => @attributes, :concession => :concession)
      @subscription = factory.build
      @subscription.pending_action.should_not be(nil)
    end
  end
end
