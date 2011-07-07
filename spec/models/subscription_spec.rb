require 'spec_helper'

describe Subscription do

  before(:each) do
    stub_wordpress
    @start_time = "2011-01-01".to_time
    Timecop.freeze(@start_time)
    @subscription = Factory.create(:subscription)
    cm_return = stub(:success? => true)
    CM::Recipient.stubs(:exists?).returns(true)
    CM::Recipient.stubs(:find_all).returns(cm_return)
    CM::Recipient.stubs(:update)
    CM::Recipient.stubs(:create!)
  end

  after(:each) do
    Timecop.return
  end

  describe "upon save" do
    it "should create a recipient in Campaign Master" do
      s = Factory.create(:subscription)
      s.expects(:send_later).with(:sync_to_campaign_master)
      s.save!
    end
  end

  it "should not allow more than one subscription with the same user and publication" do
    mypub = Factory.create(:publication)
    u = Factory.create(:user)
    u.subscriptions << Factory.create(:subscription, :publication => mypub)
    lambda {
      u.subscriptions << Factory.build(:subscription, :publication => mypub)
    }.should raise_exception
  end

  describe "reference" do
    before(:each) do
      @subscription = Factory.create(:subscription)
    end
    
    it 'should return a reference number related to the id' do
      @subscription.reference.should == ("S%07d" % @subscription.id)
    end
    
    it 'should return an id from a reference number' do
      Subscription.id_from_reference(@subscription.reference).should == @subscription.id
    end
  end

  describe "increment expiry date" do
    before(:each) do
      @offer = Factory.create(:offer)
      @subscription.offer = @offer
      Timecop.freeze(Date.new(2010, 9, 27))
    end

    after(:each) do
      Timecop.return
    end

    it "should set expiry_date to 3 months from now if the expiry date has aleady been passed" do
      @subscription.expires_at = Date.new(2010, 1, 1)
      expected = Date.new(2010, 12, 27)
      @subscription.increment_expires_at(3)
      @subscription.expires_at.localtime.year.should == expected.year
      @subscription.expires_at.localtime.month.should == expected.month
      @subscription.expires_at.localtime.day.should == expected.day
    end

    it "should set expiry_date to 3 months from now if no expiry date has been set yet" do
      expected = Date.new(2010, 12, 27)
      @subscription.increment_expires_at(3)
      @subscription.expires_at.localtime.year.should == expected.year
      @subscription.expires_at.localtime.month.should == expected.month
      @subscription.expires_at.localtime.day.should == expected.day
    end

    it "should set expiry_date to nil if a nil argument is provided" do
      @subscription.increment_expires_at(nil)
      @subscription.expires_at.should be(nil)
    end

    describe "for an active state" do
      it "should set expiry_date to 3 months from the end of current expiry date" do
        @subscription.expires_at = Date.new(2010, 10, 4)
        expected = Date.new(2011, 1, 4)
        @subscription.increment_expires_at(3)
        @subscription.expires_at.localtime.year.should == expected.year
        @subscription.expires_at.localtime.month.should == expected.month
        @subscription.expires_at.localtime.day.should == expected.day
      end
    end

    describe "if the state changes" do
      it "should set expiry date to 3 months from now even if the current expiry date is in the future" do
        @subscription = Factory.create(:expired_subscription, :expires_at => Date.new(2011, 1, 4))
        @subscription.expires_at = Date.new(2010, 10, 4)
        @subscription.state = 'active'
        expected = Date.new(2010, 12, 27)
        @subscription.increment_expires_at(3)
        @subscription.expires_at.localtime.year.should == expected.year
        @subscription.expires_at.localtime.month.should == expected.month
        @subscription.expires_at.localtime.day.should == expected.day
      end
    end
  end

  describe "apply_action" do
    # TODO: describe "to an active subscription" do - its different for new subs and renewals
    before(:each) do
      @subscription = Factory.create(:active_subscription, :expires_at => Time.now)
      @payment = Factory.build(:payment)
      @action = Factory.build(:subscription_action, :term_length => 5)
      @action.payment = @payment
      @subscription.user = Factory.build(:user)
      @subscription.publication = Factory.build(:publication)

      response = stub(:success? => true)
      GATEWAY.stubs(:purchase).returns(response)
    end

    it "should increment the expiry date" do
      Subscription.any_instance.expects(:increment_expires_at).with(5)
      @subscription.apply_action(@action)
    end

    it "should set the old expiry_date" do
      @subscription.apply_action(@action)
      @action.old_expires_at.should == @start_time
    end

    it "should set the new expiry_date" do
      @subscription.apply_action(@action)
      @action.new_expires_at.should == @start_time + 5.months
    end

    it "should add the action to the actions list" do
      expect {
        @subscription.apply_action(@action)
      }.to change { @subscription.actions.size }.by(1)
    end

    it "should increment the number of payments" do
      expect {
        @subscription.apply_action(@action)
      }.to change { Payment.count }.by(1)
    end

    it "should process the payment" do
      @payment.expects(:process!)
      @subscription.apply_action(@action)
    end

    it "should raise if no valid payment available" do
      @action.payment = nil
      lambda {
        @subscription.apply_action(@action)
      }.should raise_exception
    end

    it "should raise if the payment fails" do
      failure = stub(:success? => false, :message => "Test Failure")
      GATEWAY.expects(:purchase).returns(failure)
      lambda {
        @subscription.apply_action(@action)
      }.should raise_exception(Exceptions::PaymentFailedException)
    end

    it "should set 'renewal' to false" do
      @subscription.apply_action(@action)
      @action.renewal.should be(false)
    end

    describe "if the subscription already has an action" do
      before(:each) do
        @subscription.save!
        @subscription.actions.create(Factory.attributes_for(:subscription_action))
      end

      it "should set 'renewal' to true" do
        @subscription.apply_action(@action)
        @action.renewal.should be(true)
      end
    end
  end
  
  describe "class definition" do
    it "should return per page" do
      Subscription.per_page.should == 20
    end
    it { should belong_to :user }
    it { should belong_to :offer }
    it { should belong_to :publication }
    it { should have_many :log_entries }
    # could we easily spec accepts_nested_attributes_for?
  end

  describe "with named scopes" do
    before(:each) do
      a = Factory.create(:subscription)
      b = Factory.create(:subscription)
    end

    it "should have named_scope ascend_by_name" do
      subs = Subscription.ascend_by_name
      # XXX: sorting is by lastname, firstname. should check first name too?
      # XXX: the DBMS's sorting and ruby's sorting might use different algorithms!
      subs[0].user.lastname.should <= subs[1].user.lastname
    end

    it "should have named_scope descend_by_name" do
      subs = Subscription.descend_by_name
      subs[0].user.lastname.should >= subs[1].user.lastname
    end
  end

  describe "actions" do
    it "should return the most recently applied action first" do
      @subscription = Factory.create(:subscription)
      @subscription.actions << Factory.create(:subscription_action, :applied_at => "2011-03-01 10:00".to_time, :offer_name => "AA", :subscription => @subscription)
      @subscription.actions << Factory.create(:subscription_action, :applied_at => "2011-04-01 10:00".to_time, :offer_name => "BB", :subscription => @subscription)
      @subscription.actions.first.offer_name.should == "BB"
    end
  end

  # -------------------------- Soft Deletion Scenarios
  it "should archive the deleted subscriptions" do
    sub_primary_size = Subscription.all.size
    archive_primary_size = Subscription::Archive.all.size
    
    s = Factory.create(:subscription) # create a new subscription and save in database
    Subscription.all.size.should == sub_primary_size + 1
    Subscription::Archive.all.size.should == archive_primary_size

    # primary deletion -> artficial deletion
    s.destroy
    Subscription.all.size.should == sub_primary_size
    Subscription::Archive.all.size.should == archive_primary_size + 1

    # secondary deletion -> no changes!
    s.destroy
    Subscription.all.size.should == sub_primary_size
    Subscription::Archive.all.size.should == archive_primary_size + 1
  end
end
