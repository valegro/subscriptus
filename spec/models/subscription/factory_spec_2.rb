require 'spec_helper'

describe SubscriptionFactory do
  shared_examples_for "An active subscription" do
    it "should set the state to active" do
      factory = SubscriptionFactory.new(@offer, :attributes => @attributes)
      factory.update(@subscription)
      @subscription.state.should == 'active'
    end

    it "should add a subscription action" do
      expect {
        factory = SubscriptionFactory.new(@offer, :attributes => @attributes)
        factory.update(@subscription)
        @subscription.actions.size.should == 1
        @subscription.actions.first.offer_name.should == @offer.name
        @subscription.actions.first.price.should == @offer.offer_terms.first.price
        @subscription.actions.first.term_length.should == @offer.offer_terms.first.months
        @subscription.actions.first.applied_at.should == @t
        @subscription.save!
      }.to change { @subscription.actions.count }.by(1)
    end
    # TODO: Payments are missing here
  end

  shared_examples_for "A pending subscription" do
    before(:each) do
      factory = SubscriptionFactory.new(@offer, :attributes => @attributes, :concession => :student)
      factory.update(@subscription)
    end

    it "should have a state of pending" do
      @subscription.state.should == 'pending'
    end

    it "should have a pending action assigned" do
      @subscription.pending_action.should be_instance_of(SubscriptionAction)
    end

    it "should have a value assigned to pending" do
      @subscription.pending.should_not be(nil)
    end
  end

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

    @user_attrs = Factory.attributes_for(:user)
    @attributes = {
      'user_attributes' => @user_attrs,
      'payments_attributes' => { "0" => Factory.attributes_for(:payment) }
    }
    @t = Time.local(2011, 1, 1, 0, 0, 0)
    Timecop.freeze(@t)
  end

  after(:each) do
    Timecop.return
  end

  # Scenario
  describe "trialler subscribes and becomes active" do
    before(:each) do
      @publication = Factory.create(:publication)
      @subscription = User.find_or_create_with_trial(@publication, Publication::DEFAULT_TRIAL_EXPIRY, "", @user_attrs)
    end

    it "should modify the subscription from an instance of a factory" do
      expect {
        factory = SubscriptionFactory.new(@offer, :attributes => @attributes)
        factory.update(@subscription)
        @subscription.save!
      }.to_not change { Subscription.count }
    end
    
    it "should set the expiry date appropriately" do
      expect {
        factory = SubscriptionFactory.new(@offer, :attributes => @attributes)
        factory.update(@subscription)
      }.to change { @subscription.expires_at }.by(@term1.months.months)
    end

    it_should_behave_like "An active subscription"
  end

  # Scenario
  describe "active subscription is renewed and becomes active" do
    before(:each) do
      @subscription = Factory.create(:active_subscription)
    end

    it "should set the expiry date appropriately" do
      expect {
        factory = SubscriptionFactory.new(@offer, :attributes => @attributes)
        factory.update(@subscription)
      }.to change { @subscription.expires_at }.by(@term1.months.months)
    end

    it_should_behave_like "An active subscription"
  end

  # Scenario
  describe "active subscription is renewed but will require verifcation" do
    it "should keep the state active until the end of the current term" # How? What else?
  end

  # Scenario
  describe "trialler subscribes but requires verification" do
    before(:each) do
      @publication = Factory.create(:publication)
      @subscription = User.find_or_create_with_trial(@publication, Publication::DEFAULT_TRIAL_EXPIRY, "", @user_attrs)
    end

    it_should_behave_like "A pending subscription"
  end

  # Scenario
  describe "squatter subscribes and becomes active" do
    before(:each) do
      @subscription = Factory.create(:expired_subscription)
    end

    it "should set the expiry date appropriately" do
      factory = SubscriptionFactory.new(@offer, :attributes => @attributes)
      factory.update(@subscription)
      @subscription.expires_at.should == @term1.months.months.from_now
    end

    it_should_behave_like "An active subscription"
  end

  # Scenario
  describe "pending subscriber subscribes without concession again and becomes active" do
    before(:each) do
      @subscription = Factory.create(:pending_subscription)
    end

    it_should_behave_like "An active subscription"
  end

  # Scenario
  describe "pending subscribed subscribes again and will require verification" do
    before(:each) do
      @subscription = Factory.create(:pending_subscription)
    end

    it_should_behave_like "A pending subscription"
  end

  # TODO: More scenarios?
end
