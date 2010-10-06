require 'spec_helper'

describe Subscription do

  before(:each) do
    @subscription = Subscription.new()
    today = Date.new(2010, 9, 27) # today is "Mon, 27 Sep 2010"
    Date.stubs(:today).returns(today)
    CM::Recipient.stub!(:send)
  end

  # tests on get_new_expiry_date method ----------------
  it "should set expiry_date to 3 months from now if the expiry date has aleady been passed" do
    months = 3
    expiry_date = Date.new(2010, 1, 1)
    expected = Date.new(2010, 12, 27)
    @subscription.get_new_expiry_date(months).should == expected
  end

  it "should set expiry_date to 3 months from the end of current expiry date" do
    months = 3
    @subscription.expires_at = Date.new(2010, 10, 4)
    expected = Date.new(2011, 1, 4)
    @subscription.get_new_expiry_date(months).year.should == expected.year
    @subscription.get_new_expiry_date(months).month.should == expected.month
    @subscription.get_new_expiry_date(months).day.should == expected.day
  end

  it "should set expiry_date to 3 months from now if no expiry date has been set yet" do
    months = 3
    expected = Date.new(2010, 12, 27)
    @subscription.get_new_expiry_date(months).should == expected
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
    CM::Recipient.should_receive(:update).with(
          :fields => { :"publication_#{s.publication_id}{state}" => s.state,
                       :"publication_#{s.publication_id}{expiry}" => s.expires_at,
                       :user_id => s.user.id
          }
    ).and_return("called")
    s.update_campaignmaster.should eql("called")
  end
  it "should invoke campaingmaster update on update_campaignmaster" do
    s = Factory.create(:subscription)
    s.reload
    CM::Recipient.should_receive(:update).with(
          :fields => { :"publication_#{s.publication_id}{state}" => s.state,
                       :"publication_#{s.publication_id}{expiry}" => s.expires_at,
                       :user_id => s.user.id
          }
    ).and_return("called")
    s.update_campaignmaster.should eql("called")
  end
  # TODO: how do we log this?
  it "should log error if create fails" do
    s = Factory.build(:subscription)
    CM::Recipient.should_receive(:update).and_raise("spam")
    CM::Proxy.should_receive(:log_cm_error)
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
end
