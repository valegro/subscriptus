require 'spec_helper'

describe SubscriptionMailer do

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
  describe "if the subscription, offer an user are valid and available" do
    it "should successfully deliver the email containing the correct subscription details to the activated user" do
      subscription = Factory.stub(:subscription, :id => 1)
      res = SubscriptionMailer.deliver_activation(subscription)

      res.should_not      be_nil
      res.subject.should  == 'Crikey Online Order S0000001'
      res.to.should       == [subscription.user.email]
      res.from.should     == [SubscriptionMailer::NO_REPLY]
      res.body.should     include_text(subscription.user.firstname)
      res.body.should     include_text(subscription.user.lastname)
      # TODO: More body includes checks -> eg; gifts, end date etc
      res.content_type.should == 'text/html'
    end
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
    end
  end
end
