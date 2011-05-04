require 'spec_helper'

describe SubscribeController do

  integrate_views

  before(:each) do
    Timecop.freeze('2011-01-01 0:00')
    @source = Factory(:source)

    @user_attributes = Factory.attributes_for(:user).stringify_keys
    @payment_attributes = Factory.attributes_for(:payment).stringify_keys

    cm_return = stub(:success? => true)
    CM::Recipient.stubs(:exists?).returns(true)
    CM::Recipient.stubs(:find_all).returns(cm_return)
    CM::Recipient.stubs(:update)
    CM::Recipient.stubs(:create!)
    stub_wordpress
  end

  # Handy link: http://cheat.errtheblog.com/s/assert_select/
  describe "on new" do
    describe "when a wordpress user exists with an email and I have provided an email address" do
      before(:each) do
        @offer = Factory.create(:offer)
        @source = Factory.create(:source)
        Wordpress.stubs(:exists?).with({:email => "daniel@codefire.com.au"}).returns(true)
      end

      it "should not ask me for my details" do
        get 'new', :email => "daniel@codefire.com.au"
        response.should_not include_text("New User Sign-Up")
        response.should_not include_text("Street Address Line 1")
      end

      it "should ask me to login" do
        get 'new', :email => "daniel@codefire.com.au"
        response.should include_text("Login")
        response.should have_tag("form") do
          with_tag("input#user[login]", "user[login]")
        end
      end
    end

    describe "when a wordpress user does not exist or if I have not provided an email" do
      it "should ask me for my details"
      it "should not ask me to login"
    end

    it "should set the source for the form action" do
      response_should have_tag("form[action=/subscribe?offer_id=#{@offer.id}&source=#{@source.id}")
    end

    # TODO: More?
    # TODO: What about if the user exists in WP and there is a subscriber in Sub with that email (or what if there is not?!)
  end

  describe "on create" do
    before(:each) do
      @offer = Factory(:offer)
      @ot1 = Factory(:offer_term, :months => 1)
      @ot2 = Factory(:offer_term, :months => 3)
      @offer.offer_terms << @ot1
      @offer.offer_terms << @ot2
      @offer.gifts.add(@g1 = Factory(:gift, :on_hand => 10))
      @offer.gifts.add(@g2 = Factory(:gift, :on_hand => 10))
      @offer.gifts.add(@g3 = Factory(:gift, :on_hand => 0))
      @offer.gifts.add(@g4 = Factory(:gift, :on_hand => 10), true)

      @attributes = {
        'user_attributes' => @user_attributes
      }
    end

    it "should create a subscription" do
      expect {
        post('create', {
          :offer_id => @offer.id,
          :source_id => @source.id,
          :offer_term => @ot1.id,
          :subscription => @attributes,
          :payment => @payment_attributes
        })
      }.to change { Subscription.count }.by(1)
      Subscription.last.actions.size.should == 1
      Subscription.last.actions.last.payment.should be_an_instance_of(Payment)
      response.should redirect_to(:action => 'thanks')
    end

    it "should not create a subscription if payment fails" do
      gw_response = stub(:success? => false, :message => "Testing Failure")
      GATEWAY.expects(:purchase).returns(gw_response)
      expect {
        post('create', {
          :offer_id => @offer.id,
          :source_id => @source.id,
          :offer_term => @ot1.id,
          :subscription => @attributes,
          :payment => @payment_attributes
        })
      }.to_not change { Subscription.count }.by(1)
      response.should render_template("new")
      flash[:error].should == "Testing Failure"
    end

    it "should not create a subscription if record invalid" do
      expect {
        post('create', {
          :offer_id => @offer.id,
          :source_id => @source.id,
          :offer_term => @ot1.id,
          :subscription => {:user_attributes => {}}
        })
      }.to_not change { Subscription.count }.by(1)
      response.should render_template("new")
    end

    it "should build a subscription when no gifts are selected" do
      subscription = stub(:user => Factory.stub(:user))
      factory = stub(:build => subscription)
      SubscriptionFactory.expects(:new).with(
        instance_of(Offer), {
          :term_id => @ot1.id.to_s,
          :optional_gift => nil,
          :included_gift_ids => nil,
          :attributes => @attributes,
          :source => @source.id,
          :payment_attributes => @payment_attributes,
          :concession => nil,
          :source => @source.id.to_s
        }
      ).returns(factory)
      subscription.expects(:save!).returns(true)
      post('create', {
        :offer_id => @offer.id,
        :source_id => @source.id,
        :offer_term => @ot1.id,
        :subscription => @attributes,
        :payment => @payment_attributes
      })
      response.should redirect_to(:action => 'thanks')
    end

    it "should build a subscription with included and an optional gift" do
      subscription = stub(:user => Factory.stub(:user))
      subscription.expects(:save!).returns(true)
      factory = stub(:build => subscription)
      SubscriptionFactory.expects(:new).with(
        instance_of(Offer), {
          :term_id => @ot1.id.to_s,
          :optional_gift => nil,
          :included_gift_ids => [@g1.id, @g2.id],
          :optional_gift => @g4.id.to_s,
          :attributes => @attributes,
          :payment_attributes => @payment_attributes,
          :concession => nil,
          :source => @source.id.to_s
        }
      ).returns(factory)
      post 'create', {
        :offer_id => @offer.id,
        :source_id => @source.id,
        :included_gifts => [@g1.id, @g2.id],
        :optional_gift => @g4.id,
        :offer_term => @ot1.id,
        :subscription => @attributes,
        :payment => @payment_attributes
      }
      response.should redirect_to(:action => 'thanks')
    end

    it "should not create a subscription if an optional gift is out of stock" do
      @g4.on_hand = 0
      @g4.save
      expect {
        post('create', {
          :offer_id => @offer.id,
          :source_id => @source.id,
          :offer_term => @ot1.id,
          :optional_gift => @g4.id,
          :subscription => @attributes,
          :payment => @payment_attributes
        })
      }.to_not change { Subscription.count }.by(1)
      response.should render_template("new")
      flash[:error].should == "The Gift #{@g4.name} is no longer available"
    end

    describe "when choosing student concession" do
      before(:each) do
        GATEWAY.stubs(:trigger_recurrent)
        success = stub(:success? => true)
        GATEWAY.expects(:setup_recurrent).returns(success)
        GATEWAY.expects(:purchase).never
      end

      after(:each) do
        post('create', {
          :offer_id => @offer.id,
          :source_id => @source.id,
          :offer_term => @ot1.id,
          :subscription => @attributes,
          :payment => @payment_attributes,
          :concession => 'student'
        })
      end

      it "should set the subscription to pending" do
        subscription = stub(:save! => true)
        factory = stub(:build => subscription)
        SubscriptionFactory.expects(:new).with(
          instance_of(Offer), {
            :term_id => @ot1.id.to_s,
            :attributes => @attributes,
            :payment_attributes => @payment_attributes,
            :concession => 'student',
            :optional_gift => nil,
            :included_gift_ids => nil,
            :source => @source.id.to_s
          }
        ).returns(factory)
      end
    end

    describe "when choosing senior concession" do
      before(:each) do
        GATEWAY.stubs(:trigger_recurrent)
        success = stub(:success? => true)
        GATEWAY.expects(:setup_recurrent).returns(success)
        GATEWAY.expects(:purchase).never
      end

      after(:each) do
        post('create', {
          :offer_id => @offer.id,
          :source_id => @source.id,
          :offer_term => @ot1.id,
          :subscription => @attributes,
          :payment => @payment_attributes,
          :concession => 'concession'
        })
      end

      it "should set the subscription to pending" do
        subscription = stub(:save! => true)
        factory = stub(:build => subscription)
        SubscriptionFactory.expects(:new).with(
          instance_of(Offer), {
            :term_id => @ot1.id.to_s,
            :attributes => @attributes,
            :payment_attributes => @payment_attributes,
            :concession => 'concession',
            :optional_gift => nil,
            :included_gift_ids => nil,
            :source => @source.id.to_s
          }
        ).returns(factory)
      end
    end

    describe "when a wordpress user exists with the same email" do
      before(:each) do
        Wordpress.stubs(:exists?).with({:email => "daniel@codefire.com.au"}).returns(true)
        @attributes['user_attributes']['email'] = 'daniel@codefire.com.au'
        @attributes['user_attributes']['email_confirmation'] = 'daniel@codefire.com.au'
      end

      it "should return to the new page and ask for a username and password" do
        post('create', {
          :offer_id => @offer.id,
          :source_id => @source.id,
          :offer_term => @ot1.id,
          :optional_gift => @g4.id,
          :subscription => @attributes,
          :payment => @payment_attributes
        })
        response.should render_template("subscribe/new")
      end

      # TODO: Once again, should we also check to see if there is a user who has the email address too?
    end

    describe "when a wordpress user exists with the same login" do
      it "should return to the new page and ask for a username and password"
    end


    # TODO
    # Invalid gift
    # check error messages
    # Direct Debit
    # Existing User, wordpress etc
  end
end
