require 'spec_helper'

describe "Subscribes" do
  shared_examples_for "a new user signup" do
    it "should ask me for my details" do
      page.should have_content("New User Sign-Up")
      page.should have_content("Street Address Line 1")
    end

    it "should not ask me to login" do
      within("div#login") do
        page.should have_no_content("Email")
        within("form") do
          page.should have_no_xpath("input#email")
        end
      end
    end
  end

  describe "as a visitor to the subscribe page" do
    before(:each) do
      @offer = Factory.create(:offer)
      @source = Factory.create(:source)
    end

    it "should set the source for the form action" do
      visit new_subscribe_path(:source_id => @source.id, :offer_id => @offer.id)
      page.should have_xpath("//form[contains(@action,\"/subscribe?offer_id=#{@offer.id}&source_id=#{@source.id}\")]")
    end

    it "should not the source for the form action if none is provided" do
      visit new_subscribe_path(:offer_id => @offer.id)
      page.should have_xpath("//form[contains(@action,\"/subscribe?offer_id=#{@offer.id}\")]")
    end

    describe "when a wordpress user exists with an email and I have provided an email address" do
      before(:each) do
        Wordpress.stubs(:exists?).with({:email => "daniel@codefire.com.au"}).returns(true)
      end

      it "should not ask me for my details" do
        visit new_subscribe_path(:email => "daniel@codefire.com.au")
        page.should have_no_content("New User Sign-Up")
        page.should have_no_content("Street Address Line 1")
      end

      it "should ask me to login" do
        visit new_subscribe_path(:email => "daniel@codefire.com.au")
        within("div#login") do
          page.should have_content("Email")
          within("form") do
            page.should have_xpath("input#email")
          end
        end
      end
    end

    describe "on the students tab" do
      before(:each) do
        @offer.gifts.add(Factory.create(:gift))
      end

      it "should highlight the tab if the offer has concession terms" do
        @offer.offer_terms.create(:price => 10, :months => 3, :concession => true)
        visit new_subscribe_path(:source_id => @source.id, :offer_id => @offer.id, :tab => 'students')
        page.should have_xpath("//li[@class='active' and @id='students-tab']")
      end

      it "should highlight the subscriptions tab if the offer has no concession terms" do
        visit new_subscribe_path(:source_id => @source.id, :offer_id => @offer.id, :tab => 'students')
        page.should have_no_xpath("//li[@class='active' and @id='students-tab']")
        page.should have_xpath("//li[@class='active' and @id='subscriptions-tab']")
      end

      it "should not show any gift options if there is a concession term option" do
        @offer.offer_terms.create(:price => 10, :months => 3, :concession => true)
        visit new_subscribe_path(:source_id => @source.id, :offer_id => @offer.id, :tab => 'students')
        page.should have_no_content("Subscribe and Receive")
        page.should have_no_xpath("//div[@class='gift-option']")
      end
    end

    describe "on the concessions tab" do
      before(:each) do
        @offer.gifts.add(Factory.create(:gift))
      end

      it "should highlight the tab if the offer has concession terms" do
        @offer.offer_terms.create(:price => 10, :months => 3, :concession => true)
        visit new_subscribe_path(:source_id => @source.id, :offer_id => @offer.id, :tab => 'concessions')
        page.should have_xpath("//li[@class='active' and @id='concessions-tab']")
      end

      it "should highlight the subscriptions tab if the offer has no concession terms" do
        visit new_subscribe_path(:source_id => @source.id, :offer_id => @offer.id, :tab => 'concessions')
        page.should have_no_xpath("//li[@class='active' and @id='concessions-tab']")
        page.should have_xpath("//li[@class='active' and @id='subscriptions-tab']")
      end

      it "should not show any gift options if there is a concession term option" do
        @offer.offer_terms.create(:price => 10, :months => 3, :concession => true)
        visit new_subscribe_path(:source_id => @source.id, :offer_id => @offer.id, :tab => 'concessions')
        page.should have_no_content("Subscribe and Receive")
        page.should have_no_xpath("//div[@class='gift-option']")
      end
    end

    describe "on the groups tab" do
      before(:each) do
        @offer.gifts.add(Factory.create(:gift))
      end

      it "should highlight the tab if the offer has concession terms" do
        @offer.offer_terms.create(:price => 10, :months => 3, :concession => true)
        visit new_subscribe_path(:source_id => @source.id, :offer_id => @offer.id, :tab => 'groups')
        page.should have_xpath("//li[@class='active last' and @id='groups-tab']")
      end

      it "should highlight the subscriptions tab if the offer has no concession terms" do
        visit new_subscribe_path(:source_id => @source.id, :offer_id => @offer.id, :tab => 'groups')
        page.should have_no_xpath("//li[@class='active' and @id='groups-tab']")
        page.should have_xpath("//li[@class='active' and @id='subscriptions-tab']")
      end

      it "should not show any gift options if there is a concession term option" do
        @offer.offer_terms.create(:price => 10, :months => 3, :concession => true)
        visit new_subscribe_path(:source_id => @source.id, :offer_id => @offer.id, :tab => 'groups')
        page.should have_no_content("Subscribe and Receive")
        page.should have_no_xpath("//div[@class='gift-option']")
      end

      it "should not show any offer terms" do
        @offer.offer_terms.create(:price => 10, :months => 3, :concession => true)
        visit new_subscribe_path(:source_id => @source.id, :offer_id => @offer.id, :tab => 'groups')
        page.should have_no_content("Choose your Subscription")
        page.should have_no_xpath("//div[@class='subscription-option']")
      end
    end

    it "should show the subscriptions tab if an unknown tab name is given"
    it "should redirect to /new if visiting /subscribe without losing data on the form!"

    describe "when a wordpress user does not exist" do
      before(:each) do
        Wordpress.stubs(:exists?).with({:email => "daniel@codefire.com.au"}).returns(false)
        visit new_subscribe_path(:email => "daniel@codefire.com.au")
      end
      it_should_behave_like "a new user signup"
    end

    describe "if I have not provided an email" do
      before(:each) do
        visit new_subscribe_path
      end
      it_should_behave_like "a new user signup"
    end
  end

  describe "when I submit the form" do
    describe "if I don't fill in the data correctly" do
      it "I should see error messages"
      it "I should be on the signup page again"
    end
  end

  # TODO: Move this to another file
  describe "when I visit the subscribe page and choose student concession" do
    before(:each) do
      @offer = Factory.create(:offer)
      @term = @offer.offer_terms.create(:price => 10, :months => 3, :concession => true)
      @source = Factory.create(:source)
      GATEWAY.expects(:setup_recurrent).returns(stub(:success? => true))
      GATEWAY.expects(:purchase).never
      stub_wordpress
      visit new_subscribe_path(:source_id => @source.id, :offer_id => @offer.id, :tab => 'students')
    end

    describe "and I fill in the information correctly" do
      before(:each) do
        fill_in "First Name",            :with => "Daniel"
        fill_in "Last Name",             :with => "Draper"
        fill_in "Email",                 :with => "daniel@codefire.com.au"
        fill_in "Email confirmation",    :with => "daniel@codefire.com.au"
        fill_in "Phone number",          :with => "09090909"
        fill_in "Street Address Line 1", :with => "1 That Pl"
        fill_in "City",                  :with => "Adelaide"
        fill_in "Postcode",              :with => "5000"
        fill_in "Password",              :with => "Password1"
        fill_in "Password confirmation", :with => "Password1"
        fill_in "Name on Card",          :with => "Daniel Draper"
        fill_in "Card number",           :with => "4444333322221111"
        fill_in "Card Verification (CVV Number)", :with => "123"
        check "subscription_terms"
      end

      it "should create a pending subscription with a pending action and token payment" do
        expect {
          click "btnSubmit"
        }.to change { Subscription.count }.by(1)
        s = Subscription.last
        s.state.should == 'pending'
        s.pending_action.should be_an_instance_of(SubscriptionAction)
        s.pending_action.payment.should be_an_instance_of(Payment)
        s.pending_action.payment.payment_type.should == :token
        s.pending_action.payment.amount.should == @term.price
        s.pending_action.payment.processed_at.should be(nil)
      end
    end
  end
end
