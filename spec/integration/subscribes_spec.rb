require 'spec_helper'

describe "Subscribes" do
  describe "as a visitor to the subscribe page" do
    before(:each) do
      @offer = Factory.create(:offer)
      @term1 = @offer.offer_terms.create(:price => 10, :months => 3)
      @source = Factory.create(:source)
    end

    it "should set the source for the form action" do
      visit new_subscribe_path(:source_id => @source.id, :offer_id => @offer.id)
      page.should have_xpath("//form[contains(@action,\"/subscribe?offer_id=#{@offer.id}&source_id=#{@source.id}\")]")
    end

    it "should not set the source for the form action if none is provided" do
      visit new_subscribe_path(:offer_id => @offer.id)
      page.should have_xpath("//form[contains(@action,\"/subscribe?offer_id=#{@offer.id}\")]")
    end

    it "should display the credit card payment option" do
      visit new_subscribe_path(:offer_id => @offer.id)
      page.should have_content("Credit Card Details")
      page.should have_xpath("//input[@id='payment_full_name']")
      page.should have_xpath("//input[@id='payment_card_number']")
      page.should have_xpath("//label[@for='payment_card_expiry_date']")
      page.should have_xpath("//input[@id='payment_card_verification']")
    end

    describe "when I choose the direct debit option" do
      it "I should see the right content", :js => true do
        visit new_subscribe_path(:offer_id => @offer.id)
        choose("Direct Debit")
        find('#payment_by_direct_debit').visible?.should be(true)
        page.should have_content("Click the FINISH button below once you’ve chosen your payment option:")
        page.should have_content("BSB: 083 026")
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

      it "should not display the direct debit payment option" do
        page.should have_no_xpath("//input[@id='payment-radio-direct-debit']")
        page.should have_no_content("Click the FINISH button below once you’ve chosen your payment option:")
        page.should have_no_content("BSB: 083 026")
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

      it "should not display the direct debit payment option" do
        page.should have_no_xpath("//input[@id='payment-radio-direct-debit']")
        page.should have_no_content("Click the FINISH button below once you’ve chosen your payment option:")
        page.should have_no_content("BSB: 083 026")
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

      it "should not display the direct debit payment option" do
        page.should have_no_xpath("//input[@id='payment-radio-direct-debit']")
        page.should have_no_content("Click the FINISH button below once you’ve chosen your payment option:")
        page.should have_no_content("BSB: 083 026")
      end
    end

    it "should show the subscriptions tab if an unknown tab name is given" do
      visit new_subscribe_path(:source_id => @source.id, :offer_id => @offer.id, :tab => 'kjregherkjghre')
      page.should have_xpath("//li[@class='active' and @id='subscriptions-tab']")
    end
  end

  describe "when I visit the subscribe page and choose student concession" do
    before(:each) do
      @offer = Factory.create(:offer)
      @term = @offer.offer_terms.create(:price => 10, :months => 3, :concession => true)
      @source = Factory.create(:source)
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
        fill_in "Nominate your password",:with => "Password1"
        fill_in "Password confirmation", :with => "Password1"
        fill_in "Name on Card",          :with => "Daniel Draper"
        fill_in "Card number",           :with => "4444333322221111"
        fill_in "Card Verification (CVV Number)", :with => "123"
        choose "offer_term_#{@term.id}" 
        check "subscription_terms"
        GATEWAY.expects(:setup_recurrent).returns(stub(:success? => true))
      end

      it "should create a pending subscription with a pending action and token payment" do
        expect {
          click_link_or_button "btnSubmit"
        }.to change { Subscription.count }.by(1)
        s = Subscription.last
        s.state.should == 'pending'
        s.pending.should == :student_verification
        s.pending_action.should be_an_instance_of(SubscriptionAction)
        s.pending_action.payment.should be_an_instance_of(Payment)
        s.pending_action.payment.payment_type.should == :token
        s.pending_action.payment.amount.should == @term.price
        s.pending_action.payment.processed_at.should be(nil)
      end

      it "should display the thanks page" do
        click_link_or_button "btnSubmit"
        page.should have_content("Thanks for subscribing to Crikey! We hope you enjoy it.")
      end
    end

    describe "and I do not provide all data" do
      before(:each) do
        fill_in "First Name",            :with => "Daniel"
        fill_in "Last Name",             :with => "Draper"
        fill_in "Email",                 :with => "daniel@codefire.com.au"
        fill_in "Phone number",          :with => "09090909"
        fill_in "Street Address Line 1", :with => "1 That Pl"
        fill_in "City",                  :with => "Adelaide"
        fill_in "Postcode",              :with => "5000"
        fill_in "Password",              :with => "Password1"
        fill_in "Password confirmation", :with => "Password1"
      end

      it "should take me back to the form" do
        click_link_or_button "btnSubmit"
        page.should have_content "Subscribe to Crikey"
      end

      it "should show me any error messages" do
        click_link_or_button "btnSubmit"
        page.should have_content("Email doesn't match confirmation")
      end

      it "should be on the students tab" do
        click_link_or_button "btnSubmit"
        page.should have_xpath("//li[@id='students-tab' and @class='active']")
        page.should have_content("Are you a full-time student? Crikey offers a 30% discount on the normal subscription rate for students.")
      end
    end
  end

  describe "when I visit the subscribe page" do
    before(:each) do
      @offer = Factory.create(:offer)
      @term = @offer.offer_terms.create(:price => 10, :months => 3, :concession => true)
      @term2 = @offer.offer_terms.create(:price => 20, :months => 3)
      @source = Factory.create(:source)
      stub_wordpress
      visit new_subscribe_path(:source_id => @source.id, :offer_id => @offer.id)
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
        fill_in "Nominate your password",              :with => "Password1"
        fill_in "Password confirmation", :with => "Password1"
        fill_in "Name on Card",          :with => "Daniel Draper"
        fill_in "Card number",           :with => "4444333322221111"
        fill_in "Card Verification (CVV Number)", :with => "123"
        choose "offer_term_#{@term2.id}"
        check "subscription_terms"
      end

      it "should create a subscription" do
        GATEWAY.expects(:purchase).returns(stub(:success? => true))
        expect {
          click_link_or_button "btnSubmit"
        }.to change { Subscription.count }.by(1)
        s = Subscription.last
        s.state.should == 'active'
        s.pending_action.should be(nil)
        s.actions.size.should == 1
        s.actions.last.payment.should be_an_instance_of(Payment)
      end

      it "should display the thanks page" do
        GATEWAY.expects(:purchase).returns(stub(:success? => true))
        click_link_or_button "btnSubmit"
        page.should have_content("Thanks for subscribing to Crikey! We hope you enjoy it.")
      end

      describe "but I already registered a trial for this publication" do
        before(:each) do
          @user_attrs = Factory.attributes_for(:user, :email => "daniel@codefire.com.au")
          @subscription = User.find_or_create_with_trial(@offer.publication, 21, "test", @user_attrs)
          @user = @subscription.user
          GATEWAY.expects(:purchase).returns(stub(:success? => true))
        end

        it "should turn my subscription into an active one" do
          click_link_or_button "btnSubmit"
          page.should have_content("Thanks for subscribing to Crikey! We hope you enjoy it.")
          user = User.find(@user.id)
          user.subscriptions.count.should == 1
          user.subscriptions.last.state.should == 'active'
        end

        it "should update my personal details with the ones I provided on the form" do
          click_link_or_button "btnSubmit"
          user = User.find(@user.id)
          user.firstname.should == 'Daniel'
          user.lastname.should == 'Draper'
        end

        it "should update the user in wordpress" do
          User.any_instance.expects(:send_later).with(:sync_to_wordpress, 'Password1')
          User.any_instance.expects(:send_later).with(:sync_to_campaign_master)
          click_link_or_button "btnSubmit"
        end
      end

      describe "but I already have a squatter subscription to this publication" do
        it "should turn my subscription into an active one"
        it "should update my personal details with the ones I provided on the form"
        it "should update the user in wordpress"
      end

      describe "but I already have a matching email address in Wordpress" do
        it "should do something but I don't know what yet!"
      end

      describe "but I already have a user account with that email but no subs for the offered publication" do
        it "should do something but I don't know what yet!"
      end

      describe "but I already have an active subscription to this publication" do
        before(:each) do
          @user = Factory.create(:subscriber, :email => 'daniel@codefire.com.au')
          @subscription = Factory.create(:active_subscription, :publication => @offer.publication, :user => @user)
          click_link_or_button "btnSubmit"
        end

        it "should redirect me to the renew page" do
          page.should have_content("Login now to renew or access your account")
        end
      end
    end

    describe "and I fill in the information correctly and choose direct debit as the payment method" do
      before(:each) do
        fill_in "First Name",            :with => "Daniel"
        fill_in "Last Name",             :with => "Draper"
        fill_in "Email",                 :with => "daniel@codefire.com.au"
        fill_in "Email confirmation",    :with => "daniel@codefire.com.au"
        fill_in "Phone number",          :with => "09090909"
        fill_in "Street Address Line 1", :with => "1 That Pl"
        fill_in "City",                  :with => "Adelaide"
        fill_in "Postcode",              :with => "5000"
        fill_in "Nominate your password",              :with => "Password1"
        fill_in "Password confirmation", :with => "Password1"
        choose "offer_term_#{@term2.id}"
        check "subscription_terms"
        choose("Direct Debit")
      end

      it "should create a pending subscription with a pending action" do
        expect {
          click_link_or_button "btnSubmit"
        }.to change { Subscription.count }.by(1)
        s = Subscription.last
        s.state.should == 'pending'
        s.pending.should == :payment
        s.pending_action.should be_an_instance_of(SubscriptionAction)
        s.pending_action.payment.should be_an_instance_of(Payment)
        s.pending_action.payment.payment_type.should == :direct_debit
        s.pending_action.payment.amount.should == @term2.price
        s.pending_action.payment.processed_at.should be(nil)
      end

      it "should display the thanks page" do
        GATEWAY.expects(:purchase).never
        click_link_or_button "btnSubmit"
        page.should have_content("Thanks for subscribing to Crikey! We hope you enjoy it.")
      end
    end

    describe "and I do not provide all data and choose direct debit as the payment method" do
      before(:each) do
        fill_in "First Name",            :with => "Daniel"
        fill_in "Last Name",             :with => "Draper"
        fill_in "Email",                 :with => "daniel@codefire.com.au"
        check "subscription_terms"
        choose("Direct Debit")
      end

      it "should take me back to the form" do
        click_link_or_button "btnSubmit"
        page.should have_content "Subscribe to Crikey"
      end

      it "and I should see the direct debit payment option", :js => true do
        click_link_or_button "btnSubmit"
        find('#payment_by_direct_debit').visible?.should be(true)
      end
    end

    describe "and I do not provide all data" do
      before(:each) do
        fill_in "First Name",            :with => "Daniel"
        fill_in "Last Name",             :with => "Draper"
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
        GATEWAY.expects(:purchase).never
      end

      it "should take me back to the form" do
        click_link_or_button "btnSubmit"
        page.should have_content "Subscribe to Crikey"
      end

      describe "and I fill in the missing data and submit again" do
        it "should display the thanks page"
        it "should create a subscription"
      end

      describe "but I already registered a trial for this publication" do
        before(:each) do
          @user_attrs = Factory.attributes_for(:user, :email => "daniel@codefire.com.au")
          @subscription = User.find_or_create_with_trial(@offer.publication, 21, "test", @user_attrs)
          @user = @subscription.user
          GATEWAY.expects(:purchase).returns(stub(:success? => true))
        end

        it "should take me back to the form"
        it "should show me the password fields"

        describe "and I fill in the missing data and submit again" do
          it "should upgrade my subscription to active"
        end
      end
    end
  end

  describe "when I visit the subscribe page but I don't provide an offer" do
    before(:each) do
      @source = Factory.create(:source)
      stub_wordpress
    end

    it "should use the primary offer if one is set" do
      @offer1 = Factory.create(:offer)
      @offer1.offer_terms << Factory.create(:offer_term, :months => 1)
      @offer2 = Factory.create(:offer)
      @offer2.offer_terms << Factory.create(:offer_term, :months => 2)
      @offer1.offer_terms.size.should == 1

      @offer2.make_primary!

      visit new_subscribe_path(:source_id => @source.id)
      page.should have_content("2 months")
    end

    it "should just use the first offer found if there is no primary offer" do
      @offer1 = Factory.create(:offer)
      @offer1.offer_terms << Factory.create(:offer_term, :months => 1)
      @offer2 = Factory.create(:offer)
      @offer2.offer_terms << Factory.create(:offer_term, :months => 2)
      @offer1.offer_terms.size.should == 1

      visit new_subscribe_path(:source_id => @source.id)
      page.should have_content("1 month")
    end
  end
end
