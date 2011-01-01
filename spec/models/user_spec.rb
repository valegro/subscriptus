require 'spec_helper'
describe User do
  before(:each) do
    @user = Factory.build(:subscriber)
    @user.stubs(
                     :address_1 => 'a1',
                     :address_2 => 'a2',
                     :city => 'city',
                     :country => 'country',
                     :firstname => 'first',
                     :lastname => 'last',
                     :phone_number => 'number',
                     :postcode => 'post',
                     :state => 'SA',
                     :title => 'Rev',
                     :password => 'password',
                     :password_confirmation => 'password'
               )
    cm_return = stub(:success? => true)
  end

  it "should create a trial user" do
    cnt = User.count
    user = User.create_trial_user(:first_name => 'Daniel', :last_name => 'Draper', :email => 'daniel@netfox.com')
    user.login.should == 'trial_user'
    user.auto_created.should == true
    user.password.length.should == 8
    User.count.should == cnt + 1
    # Attempt a duplicate email
    lambda {
      User.create_trial_user(:first_name => 'Daniel', :last_name => 'Draper', :email => 'daniel@netfox.com')
    }.should raise_exception
    User.count.should == cnt + 1
    # And another with a different email
    user2 = User.create_trial_user(:first_name => 'Daniel', :last_name => 'Draper', :email => 'daniel2@netfox.com')
    User.count.should == cnt + 2
    # Check different passwords
    user.password.should_not == user2.password
  end

  it "should only allow one trial per publication" do
    publication = Factory.build(:publication)
    @user.save!
    @user.subscriptions.count.should == 0
    @user.subscriptions.create(:publication => publication)
    @user.subscriptions.count.should == 1
    lambda {
      @user.subscriptions.create(:publication => publication)
    }.should raise_exception
    # Change the first subscription to active
    @user.subscriptions.first.activate!
    @user.subscriptions.first.state.should == 'active'
    lambda {
      @user.subscriptions.create(:publication => publication)
    }.should_not raise_exception
    @user.subscriptions.count.should == 2
    @user.subscriptions.trial.count.should == 1
  end

  it "should show active subscriptions" do
    publication = Factory.build(:publication)
    @user.save!
    @user.subscriptions.count.should == 0
    @user.subscriptions.create(:publication => publication)
    @user.subscriptions.count.should == 1
    @user.has_active_subscriptions?.should_not == true
    # Add an active
    @user.subscriptions.create(:publication => publication, :state => 'active')
    @user.subscriptions.count.should == 2
    @user.has_active_subscriptions?.should == true
  end

  describe "class def" do
    # test acts_as_authentic?
    it { should have_many :audit_log_entries }
    it { should have_many :subscriptions }
    it { should respond_to :email_confirmation }
    it { should respond_to :title } # XXX: test enum?
    it { should respond_to :state } # XXX: test enum?
    it { should validate_presence_of :firstname }
    it { should validate_presence_of :lastname }
    it { should validate_presence_of :email }
    it { should validate_presence_of :phone_number }
    it { should validate_presence_of :address_1 }
    it { should validate_presence_of :city }
    it { should validate_presence_of :postcode }
    it { should validate_presence_of :state }
    it { should validate_presence_of :country }
    # test validates_format_of?
  end

  describe "validating" do
    it "should cause error if email confirmation missing"
    it "should cause error if email confirmation not matching"
  end

  it "should return full name" do
    User.new(:firstname => 'spam', :lastname => 'ham').fullname.should == 'spam ham'
  end

  describe "upon creation" do
    it "should call update_cm with :create" do
      UserMailer.expects(:deliver_new_user)
      @user.expects(:send_later).with(:sync_to_campaign_master)
      @user.save!
    end

    it "should have a 20 digit gateway_token" do
      @user.save!
      @user.gateway_token.length.should == 20
    end
  end

  describe "upon update" do
    it "should call sync_to_campaign_master" do
      @user.save!
      @user.expects(:send_later).with(:sync_to_campaign_master)
      @user.save!
    end
  end

  describe "upon call to sync_to_campaign_master" do
    it "should call sync on all subscriptions" do
      @user.save!
      @subscription = Factory.build(:subscription)
      @user.subscriptions << @subscription
      @subscription.expects(:sync_to_campaign_master)
      @user.sync_to_campaign_master
    end
  end
end
