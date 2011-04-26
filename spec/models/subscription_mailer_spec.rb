require 'spec_helper'

describe SubscriptionMailer do

  shared_examples_for "an email with an unsubscribe link" do
    it "should include the unsubscribe link" do
      @response.body.should include_text("you can unsubscribe here: http://example.com/unsubscribe?user_id=#{@subscription.user.id}")
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

  describe "if the user is inavlid" do
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
      @subscription = Factory.stub(:suspended_subscription, :id => 1)
      @response = SubscriptionMailer.deliver_suspended(@subscription)
    end

    # TODO: More
    it_should_behave_like "an email with an unsubscribe link"
  end

  describe "deliver unsuspended" do
    before(:each) do
      @subscription = Factory.stub(:subscription, :id => 1)
      @response = SubscriptionMailer.deliver_unsuspended(@subscription)
    end

    # TODO: More
    it_should_behave_like "an email with an unsubscribe link"
  end
end
