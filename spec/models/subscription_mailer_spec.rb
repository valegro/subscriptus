require 'spec_helper'

describe SubscriptionMailer do

  before(:each) do
    @offer = Factory(:offer)
    @user = Factory(:user)
    @offer.publication_id = Factory(:publication).id
  end

  # tests on activation method ----------------
  describe "if the subscription, offer an user are valid and available" do
    it "should successfully deliver the email containing the correct subscription details to the activated user" do
      valid_params = { :offer_id => @offer.id,
                        :price => 20,
                        :user_id => @user.id}
      subscription = Subscription.create(valid_params)
      subscription.order_num = 333
      res = SubscriptionMailer.deliver_activation(subscription)

      res.should_not      be_nil
      res.subject.should  == 'Crikey Online Order 333'
      res.to.should       == [@user.email]
      res.from.should     == SubscriptionMailer::SEND_TO
      res.body.should     include_text(@user.firstname)
      res.body.should     include_text(@user.lastname)
      res.body.should     include_text(@offer.publication.name)
      #FIXME add more body.should include
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
end
