require 'spec_helper'

describe Subscription do

  before(:each) do
    @subscription = Subscription.new()
    today = Date.new(2010, 9, 27) # today is "Mon, 27 Sep 2010"
    Date.stubs(:today).returns(today)


    cm_return = stub(:success? => true)
    CM::Recipient.stubs(:exists?).returns(true)
    CM::Recipient.stubs(:find_all).returns(cm_return)
    CM::Recipient.stubs(:update)
    CM::Recipient.stubs(:create!)
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
  
  describe "class definition" do
    it "should return per page" do
      Subscription.per_page.should == 20
    end
    it { should belong_to :user }
    it { should belong_to :offer }
    it { should belong_to :publication }
    it { should have_many :log_entries }
    it { should have_many :subscription_gifts }
    it { should have_many :gifts }
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
end
