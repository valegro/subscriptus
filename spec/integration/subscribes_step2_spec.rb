require 'spec_helper'

describe "Subscribes", "step 2" do
  describe "when I have subscribed and I am on the thanks page" do
    before(:each) do
      @publication = Factory.create(:publication, :custom_domain => 'example.com', :name => 'Crikey!', :weekend_edition => true)
      SubscribeController.any_instance.stubs(:current_domain).returns('example.com')
      @offer = Factory.create(:offer, :publication => @publication)
      @gift = Factory.create(:gift)
      @offer.gifts << @gift
      @term = @offer.offer_terms.create(:price => 10, :months => 3, :concession => true)
      @term2 = @offer.offer_terms.create(:price => 10, :months => 3)
      @source = Factory.create(:source)
      stub_wordpress
      visit new_subscribe_path(:source_id => @source.id, :offer_id => @offer.id)
      choose "offer_term_#{@term2.id}" 
      fill_in "First Name",            :with => "Subscriptus"
      fill_in "Last Name",             :with => "Support"
      fill_in "Email",                 :with => "support@subscriptus.com.au"
      fill_in "Email confirmation",    :with => "support@subscriptus.com.au"
      fill_in "Phone number",          :with => "09090909"
      fill_in "Street Address Line 1", :with => "22 William Street"
      fill_in "City",                  :with => "Melbourne"
      fill_in "Postcode",              :with => "3000"
      fill_in "Nominate your password",              :with => "Password1"
      fill_in "Password confirmation", :with => "Password1"
      fill_in "Name on Card",          :with => "Subscriptus Support"
      fill_in "Card number",           :with => "4444333322221111"
      fill_in "Card Verification (CVV Number)", :with => "123"
      check "subscription_terms"
      GATEWAY.expects(:purchase).returns(stub(:success? => true))
      click_link_or_button "btnSubmit"
    end

    describe "and I leave both check boxes blank" do
      before(:each) do
        uncheck "weekender"
        uncheck "subscription_solus"
      end

      it "the subscription should have solus set to false" do
        click_link_or_button "btnSubmit"
        subscription = Subscription.last
        subscription.solus.should be(false)
      end

      it "I should be on the complete page" do
        click_link_or_button "btnSubmit"
        page.should have_content("Thanks! Your registration is complete.")
      end

      it "should not create an additional subscription for weekender" do
        expect {
          click_link_or_button "btnSubmit"
        }.to_not change { Subscription.count }
      end
    end

    describe "and I check solus" do
      before(:each) do
        uncheck "weekender"
        check "subscription_solus"
      end

      it "the subscription should have solus set to true" do
        click_link_or_button "btnSubmit"
        subscription = Subscription.last
        subscription.solus.should be(true)
      end

      it "I should be on the complete page" do
        click_link_or_button "btnSubmit"
        page.should have_content("Thanks! Your registration is complete.")
      end
    end

    describe "and I check weekender" do
      before(:each) do
        check "weekender"
        uncheck "subscription_solus"
      end

      it "should create an additional subscription for weekender" do
        @weekender = Factory.create(:publication, :name => "Crikey Weekender")
        expect {
          click_link_or_button "btnSubmit"
        }.to change { Subscription.count }.by(1)
        Subscription.last.publication.should == @weekender
      end

      describe "if there is no publication called Crikey Weekender" do
        it "should render the 404 page"
      end
    end

    describe "and I click view my invoice link" do
      before(:each) do
        click_link_or_button "View and print your invoice for your records"
      end

      it "should display TAX Invoice" do
        page.should have_content("TAX INVOICE")
        page.should have_content("ABN 98 101 558 847")
      end

      it "should display the gifts I chose" do
        page.should have_content("Included Gifts")
        page.should have_content(@gift.name)
      end

      it "should display my details" do
        page.should have_content("Subscriptus Support")
        page.should have_content("support@subscriptus.com.au")
      end

      it "should display the payment amount and order number" do
        subscription = Subscription.last
        page.should have_content(subscription.reference)
        page.should have_content("$#{subscription.actions.last.payment.amount}")
      end
    end
  end
end
