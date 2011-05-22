require 'spec_helper'

describe SubscriptionMailer do

  shared_examples_for "an email with an unsubscribe link" do
    it "should include the unsubscribe link" do
      @response.body.should include_text("you can unsubscribe") 
      @response.body.should include_text("http://example.com/unsubscribe?user_id=#{@subscription.user.id}")
    end
    it "should include the recipients email address" do
      @response.body.should include_text("Your email address is registered as #{@subscription.user.email}")
    end
  end

  before(:each) do
    stub_wordpress
    @offer = Factory(:offer)
    @offer_term = Factory.create(:offer_term, :months => 3, :offer_id => @offer.id)
    @user = Factory(:subscriber)
    @offer.publication_id = Factory(:publication).id
    Timecop.freeze("2011-01-01".to_time)
  end

  after(:each) do
    Timecop.return
  end

  # tests on activation method ----------------
  describe "deliver activation" do
    before(:each) do
      @subscription = Factory.create(:subscription)
      action = Factory.create(:subscription_action, :payment => Factory.create(:payment), :subscription => @subscription)
      @subscription.actions << action
      @subscription.save!
      @response = SubscriptionMailer.deliver_activation(@subscription)
    end

    it "should successfully deliver the email containing the correct subscription details to the activated user" do
      @response.should_not      be_nil
      @response.subject.should  == "Crikey Online Order #{@subscription.reference}"
      @response.to.should       == [@subscription.user.email]
      @response.from.should     == [SubscriptionMailer::NO_REPLY]
      @response.body.should     include_text(@subscription.user.firstname)
      @response.body.should     include_text(@subscription.user.lastname)
      # TODO: More body includes checks -> eg; gifts, end date etc
      @response.content_type.should == 'text/html'
    end

    # Every Email should have an unsubscribe
    it_should_behave_like "an email with an unsubscribe link"
  end

  describe "if the user is invalid" do
    it "should raise an error with the corrent message and not send the email" do
      invalid_params = {:offer_id => @offer.id,
                        :price => 20,
                        :user_id => nil}
      subscription = Subscription.create(invalid_params)
      lambda { SubscriptionMailer.deliver_activation(subscription) }.should raise_error(Exceptions::EmailDataError, "nil user/ email")
    end
  end

  describe "deliver verified" do
    before(:each) do
      @subscription = Factory.stub(:subscription, :id => 1, :state_updated_at => Time.now, :expires_at => 3.months.from_now)
      @response = SubscriptionMailer.deliver_verified(@subscription)
    end

    it "should set the correct start and end dates for the subscription" do
      @response.from.should     == [SubscriptionMailer::NO_REPLY]
      @response.body.should     include_text(@subscription.user.firstname)
      @response.body.should     include_text(@subscription.user.lastname)
      @response.body.should     include_text(@subscription.user.email)
      @response.body.should     include_text("Subscription starts: #{@subscription.state_updated_at.strftime("%d/%m/%Y")}")
      @response.body.should     include_text("Subscription ends: #{@subscription.expires_at.strftime("%d/%m/%Y")}")
      @response.body.should     include_text(@subscription.publication.forgot_password_link)
    end

    # Every Email should have an unsubscribe
    it_should_behave_like "an email with an unsubscribe link"
  end

  describe "deliver new trial" do
    before(:each) do
      @user = Factory.stub(:user, :password => 'testpass')
      @subscription = Factory.stub(
        :subscription,
        :id => 1,
        :state_updated_at => Time.now,
        :expires_at => 3.months.from_now,
        :user => @user,
        :state => 'trial',
        :temp_password => 'testpass'
      )
      @response = SubscriptionMailer.deliver_new_trial(@subscription)
    end

    it "should include the password in the email" do
      @response.body.should include_text('testpass')
    end

    it "should include the email address" do
      @response.body.should include_text(@user.email)
    end
  end

  describe "deliver expired" do
    before(:each) do
      @subscription = Factory.stub(:expired_subscription, :id => 1)
      @response = SubscriptionMailer.deliver_expired(@subscription)
    end

    # TODO: More
    it_should_behave_like "an email with an unsubscribe link"
  end

  describe "deliver suspended" do
    before(:each) do
      @subscription = Factory.build(:suspended_subscription, :id => 1)
      @subscription.stubs(:state_updated_at).returns("2011-02-02".to_time)
      @subscription.stubs(:state_expires_at).returns("2011-02-10".to_time)
      @response = SubscriptionMailer.deliver_suspended(@subscription)
      @subscription.save!
    end

    it "should include the suspend start and end dates" do
      @response.body.should     include_text("suspended from 02/02/2011 to 10/02/2011")
      @response.body.should     include_text("Your subscription will restart automatically on 10/02/2011")
    end

    it "should contain the users name" do
      @response.body.should     include_text(@subscription.user.firstname)
      @response.body.should     include_text(@subscription.user.lastname)
    end

    it_should_behave_like "an email with an unsubscribe link"
  end

  describe "deliver unsuspended" do
    before(:each) do
      @subscription = Factory.stub(:subscription, :id => 1)
      @subscription.stubs(:state_updated_at).returns("2011-02-02".to_time)
      @subscription.stubs(:state_expires_at).returns("2011-02-10".to_time)
      @response = SubscriptionMailer.deliver_unsuspended(@subscription)
    end

    it "should include the suspend start and end dates" do
      @response.body.should     include_text("suspended from 02/02/2011 to 10/02/2011")
    end

    it "should contain the users name" do
      @response.body.should     include_text(@subscription.user.firstname)
      @response.body.should     include_text(@subscription.user.lastname)
    end

    it_should_behave_like "an email with an unsubscribe link"
  end

  describe "deliver pending student" do
    before(:each) do
      Timecop.freeze("2011-02-02".to_time)
      @user = Factory.create(:user)
      @subscription = Factory.build(:pending_subscription, :pending => 'student_verification', :user => @user)
      @subscription.send(:create_without_callbacks)
      @subscription.stubs(:created_at).returns("2011-02-02".to_time)
      @response = SubscriptionMailer.deliver_pending_student_verification(@subscription)
    end

    after(:each) do
      Timecop.return
    end

    it "should include the right email and name" do
      @response.from.should     == [SubscriptionMailer::NO_REPLY]
      @response.body.should     include_text(@subscription.user.firstname)
      @response.body.should     include_text(@subscription.user.lastname)
      @response.body.should     include_text(@subscription.user.email)
    end

    it "should include the creation date" do
      @response.body.should     include_text("you signed up to our discount student rate on 02/02/2011")
    end

    it_should_behave_like "an email with an unsubscribe link"
  end

  describe "deliver pending concession" do
    before(:each) do
      Timecop.freeze("2011-02-02".to_time)
      @user = Factory.create(:user)
      @subscription = Factory.build(:pending_subscription, :pending => 'concession_verification', :user => @user)
      @subscription.send(:create_without_callbacks)
      @subscription.stubs(:created_at).returns("2011-02-02".to_time)
      @response = SubscriptionMailer.deliver_pending_concession_verification(@subscription)
    end

    after(:each) do
      Timecop.return
    end

    it "should include the right email and name" do
      @response.from.should     == [SubscriptionMailer::NO_REPLY]
      @response.body.should     include_text(@subscription.user.firstname)
      @response.body.should     include_text(@subscription.user.lastname)
      @response.body.should     include_text(@subscription.user.email)
    end

    it "should include the creation date" do
      @response.body.should     include_text("you signed up to our discount seniors/concession rate on 02/02/2011")
    end

    it_should_behave_like "an email with an unsubscribe link"
  end

  describe "deliver pending payment" do
    before(:each) do
      Timecop.freeze("2011-02-02".to_time)
      @user = Factory.create(:user)
      @subscription = Factory.build(:pending_subscription, :pending => 'payment', :user => @user)
      @subscription.send(:create_without_callbacks)
      @subscription.stubs(:created_at).returns("2011-02-02".to_time)
      @response = SubscriptionMailer.deliver_pending_payment(@subscription)
    end

    after(:each) do
      Timecop.return
    end

    it "should include the right email and name" do
      @response.from.should     == [SubscriptionMailer::NO_REPLY]
      @response.body.should     include_text(@subscription.user.firstname)
      @response.body.should     include_text(@subscription.user.lastname)
      @response.body.should     include_text(@subscription.user.email)
    end

    it "should include the creation date" do
      @response.body.should     include_text("you subscribed to Crikey on&nbsp;on 02/02/2011 and opted to pay by direct debit")
    end

    it_should_behave_like "an email with an unsubscribe link"
  end
end
