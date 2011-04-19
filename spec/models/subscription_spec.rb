require 'spec_helper'

describe Subscription do

  before(:each) do
    @subscription = Subscription.new()
    cm_return = stub(:success? => true)
    CM::Recipient.stubs(:exists?).returns(true)
    CM::Recipient.stubs(:find_all).returns(cm_return)
    CM::Recipient.stubs(:update)
    CM::Recipient.stubs(:create!)
    stub_wordpress
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
    
    it "should set expiry_date to 3 months from the end of current expiry date" do
      @subscription.expires_at = Date.new(2010, 10, 4)
      expected = Date.new(2011, 1, 4)
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
  end

  describe "apply_action" do
    before(:each) do
      @action = Factory.create(:subscription_action, :term_length => 5)
    end

    it "should increment the expiry date" do
      @subscription.expects(:increment_expires_at).with(5)
      @subscription.apply_action(@action)
    end

    it "should add the action to the actions list" do
      expect {
        @subscription.apply_action(@action)
      }.to change { @subscription.actions.size }.by(1)
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
  
  #TODO: Test all state transitions
  describe "a pending subscription" do
    before(:each) do
      SubscriptionMailer.stubs(:deliver_pending)
      @s = Factory.create(:subscription,
                          :state => "pending",
                          :pending => :concession_verification,
                          :pending_action => Factory.create(:subscription_action)
                         )
    end

    describe "upon verify" do
      it "should deliver an email" do
        SubscriptionMailer.expects(:deliver_verified).with(@s)
        @s.verify!
      end

      it "should apply an action" do
        @subscription.expects(:apply_action) #.with?
        @s.verify!
      end

      #TODO: Test student verify and concession verify
      # TODO: Test delayed payments - ie; payment processed at verify time
    end
  end

  describe "a trial subscription" do
    before(:each) do
      @json_hash = { "last_name"=>["Draper"], "first_name"=>["Daniel"], "email"=>["example@example.com"], "ip_address"=>"150.101.226.181" }
      @referrer = "http://www.example.com/referral"
      @publication = Factory.create(:publication)
    end

    it "should be created and setup correctly" do
      t = "2011-01-01 9:00".to_time(:utc).in_time_zone('UTC')
      Timecop.travel(t) do
        # TODO: This a User create but returns a subscription! Eeek! Maybe move to the association? Or return the user? Or rename the method? Or move to subscription?
        @subscription = User.find_or_create_with_trial(@publication, Publication::DEFAULT_TRIAL_EXPIRY, @referrer, @json_hash)
        @subscription.user.subscriptions.size.should == 1
        @subscription.user.lastname.should == 'Draper'
        @subscription.user.firstname.should == 'Daniel'
        @subscription.user.email.should == 'example@example.com'
        # TODO: Should solus be on the user or the subscription?
        @subscription.solus.should == false
        @subscription.state.should == 'trial'
        @subscription.expires_at.to_s.should == (t + Publication::DEFAULT_TRIAL_EXPIRY.days).to_s
      end
    end

    it "should expire after 21 days" do
      t = "2011-01-01 9:00".to_time(:utc).in_time_zone('UTC')
      Timecop.travel(t) do
        @subscription = User.find_or_create_with_trial(@publication, Publication::DEFAULT_TRIAL_EXPIRY, @referrer, @json_hash)
        Timecop.travel(t + Publication::DEFAULT_TRIAL_EXPIRY.days + 1.minute) do
          Subscription.expire_states
          @subscription.reload
          @subscription.state.should == 'squatter'
        end
      end
    end
  end
end
