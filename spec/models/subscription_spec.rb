require 'spec_helper'

describe Subscription do

  before(:each) do
    @subscription = Subscription.new()
    today = Date.new(2010, 9, 27) # today is "Mon, 27 Sep 2010"
    Date.stubs(:today).returns(today)
    CM::Recipient.stubs(:update)
    CM::Recipient.stubs(:create!)
  end

  describe "offer term" do
    before(:each) do
      months = 3
      @offer_term = Factory.create(:offer_term, :months => months)
    end

    it "should set expiry_date to 3 months from now if the expiry date has aleady been passed" do
      @subscription.expires_at = Date.new(2010, 1, 1)
      expected = Date.new(2010, 12, 27)
      @subscription.increment_expires_at(@offer_term)
      @subscription.expires_at.localtime.year.should == expected.year
      @subscription.expires_at.localtime.month.should == expected.month
      @subscription.expires_at.localtime.day.should == expected.day
    end
    
    it "should set expiry_date to 3 months from the end of current expiry date" do
      @subscription.expires_at = Date.new(2010, 10, 4)
      expected = Date.new(2011, 1, 4)
      @subscription.increment_expires_at(@offer_term)
      @subscription.expires_at.localtime.year.should == expected.year
      @subscription.expires_at.localtime.month.should == expected.month
      @subscription.expires_at.localtime.day.should == expected.day
    end
    
    it "should set expiry_date to 3 months from now if no expiry date has been set yet" do
      expected = Date.new(2010, 12, 27)
      @subscription.increment_expires_at(@offer_term)
      @subscription.expires_at.localtime.year.should == expected.year
      @subscription.expires_at.localtime.month.should == expected.month
      @subscription.expires_at.localtime.day.should == expected.day
    end
  end
  
  describe "class def" do
    it "should return per page" do
      Subscription.per_page.should == 20
    end
    it { should belong_to :user }
    it { should belong_to :offer }
    it { should belong_to :publication }
    it { should have_many :subscription_log_entries }
    it { should have_many :subscription_gifts }
    it { should have_many :gifts }
    # could we easily spec accepts_nested_attributes_for?
    # could we easily spec wizardly stuff?
  end

  describe "upon creation" do
    it "should deliver a trial email for new trials" do
      SubscriptionMailer.expects(:deliver_new_trial)
      @subscription = Factory.create(:subscription)
    end

    it "should deliver an active email for new active subscriptions" do
      #SubscriptionMailer.expects(:deliver_new_trial).never
      SubscriptionMailer.expects(:deliver_activation)
      @user = Factory.create(:subscriber)
      @user.subscriptions << Factory.create(:subscription, :state => :active)
    end
  end

  describe "with filters" do
    it "should set publication id before create" do
      s = Factory.build(:subscription)
      s.publication_id = nil
      s.save!
      s.publication_id.should_not be_nil
    end

    it "should create dlayed job" do
      lambda { Factory.create(:subscription) }.should change(Delayed::Job, :count).by(1)
    end
  end

  it "should invoke campaingmaster update on add_to_campaignmaster" do
    s = Factory.build(:subscription)
    CM::Recipient.expects(:update).with(
          :fields => { :"publication_#{s.publication_id}{state}" => s.state,
                       :"publication_#{s.publication_id}{expiry}" => s.expires_at,
                       :user_id => s.user.id
          }
    ).returns("called")
    s.update_campaignmaster.should eql("called")
  end

  it "should invoke campaingmaster update on update_campaignmaster" do
    s = Factory.create(:subscription)
    s.reload
    CM::Recipient.expects(:update).with(
          :fields => { :"publication_#{s.publication_id}{state}" => s.state,
                       :"publication_#{s.publication_id}{expiry}" => s.expires_at,
                       :user_id => s.user.id
          }
    ).returns("called")
    s.update_campaignmaster.should eql("called")
  end

  # TODO: how do we log this?
  it "should log error if create fails" do
    s = Factory.build(:subscription)
    CM::Recipient.expects(:update).raises("spam")
    CM::Proxy.expects(:log_cm_error)
    s.update_campaignmaster
  end

  describe "with named scopes" do
    before(:each) do
      Factory.create(:subscription)
      Factory.create(:subscription)
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
    
    s = Factory(:subscription) # create a new subscription and save in database
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
