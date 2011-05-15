require 'spec_helper'

describe "Subscribes", "step 2" do
  describe "when I have subscribed and I am on the thanks page" do
    before(:each) do
      @offer = Factory.create(:offer)
      @term = @offer.offer_terms.create(:price => 10, :months => 3, :concession => true)
      @source = Factory.create(:source)
      stub_wordpress
      visit new_subscribe_path(:source_id => @source.id, :offer_id => @offer.id)
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
  end
end
