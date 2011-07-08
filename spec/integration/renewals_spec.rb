require 'spec_helper'

describe "Renewals", :type => :integration do
  before(:each) do
    stub_wordpress
  end

  describe "when I visit the renewals page" do
    describe "and I am an admin" do
      before(:each) do
        @publication = Factory.create(:publication, :custom_domain => 'example.com')
        @offer = Offer.new(Factory.attributes_for(:offer))
        @offer.publication = @publication
        @offer.save!
        @offer.offer_terms.create(Factory.attributes_for(:offer_term, :months => 1))
        @offer.offer_terms.create(Factory.attributes_for(:offer_term, :concession => true, :months => 3))
        @user = Factory.create(:admin, :firstname => 'Daniel')
        @subscriber = Factory.create(:subscriber)
        @subscriber.subscriptions.clear
        @subscription = Factory.build(:active_subscription)
        @subscription.publication = @publication
        @subscription.user = @subscriber
        @subscription.save!
        @subscriber.subscriptions << @subscription
        SubscribeController.any_instance.stubs(:current_user).returns(@user)
        SubscribeController.any_instance.stubs(:current_domain).returns('example.com')
        Admin::SubscriptionsController.any_instance.stubs(:current_user).returns(@user)
      end

      it "I should be taken to the admin root" do
        visit "/renew"
        current_url.should == 'http://www.example.com/admin/subscriptions'
      end

      describe "and I provide a renewal_for parameter" do
        before(:each) do
          visit "/renew?for=#{@subscription.id}"
        end

        it "should show me the renewal page for that user" do
          current_url.should == "http://www.example.com/renew?for=#{@subscription.id}"
          page.should have_xpath("//input[@value='#{@subscriber.firstname}' and @id='user_firstname']")
        end

        describe "and I click the students tab" do
          before(:each) do
            click_link_or_button "STUDENTS"
          end

          it "should show me the concession options" do
            page.should have_content("3 months")
          end
        end

        describe "and I submit without entering my payment details" do
          before(:each) do
            click_link_or_button "btnSubmit"
          end

          it "should show me the renewal page for the subscriber" do
            current_url.should == "http://www.example.com/renew?for=#{@subscription.id}&offer_id=#{@offer.id}&tab=subscriptions"
          end

          it "should display any errors" do
            page.should have_content("Card number can't be blank")
            page.should have_content("First name on the credit card needs to be provided")
            page.should have_content("Last name on the credit card needs to be provided")
            page.should have_content("Credit Card is not valid - check the details and try again")
          end

          describe "and on the second attempt I enter all the required information" do
            before(:each) do
              GATEWAY.expects(:purchase).returns(stub(:success? => true, :params => { 'ponum' => '12345' }))
              fill_in "Name on Card",          :with => "Daniel Draper"
              fill_in "Card number",           :with => "4444333322221111"
              fill_in "Card Verification (CVV Number)", :with => "123"
              click_link_or_button "btnSubmit"
            end

            it "should take me back to the admin page for the subscription" do
              current_url.should == "http://www.example.com/admin/subscriptions/#{@subscriber.subscriptions.last.id}"
            end
          end
        end
      end
    end

    describe "and I provide a for option but I am not an admin" do
      before(:each) do
        SubscribeController.any_instance.stubs(:current_user).returns(nil)
        Admin::SubscriptionsController.any_instance.stubs(:current_user).returns(nil)
        @offer = Factory.create(:offer)
      end

      it "should redirect me to the login page" do
        visit "/renew?for=123"
        current_url.should == 'http://www.example.com/login'
      end
    end

    describe "and no offer is set" do
      before(:each) do
        @publication = Factory.create(:publication)
        @publication_with_default_set = Factory.create(:publication)
        @offera = Factory.create(:offer, :name => "ABC", :publication => @publication)
        @offerb = Factory.create(:offer, :name => "DEF", :publication => @publication)
        @offerc = Factory.create(:offer, :publication => @publication_with_default_set)
        @offerd = Factory.create(:offer, :publication => @publication_with_default_set)

        @terma = Factory.create(:offer_term, :price => 100, :months => 1)
        @termb = Factory.create(:offer_term, :price => 200, :months => 2)
        @termc = Factory.create(:offer_term, :price => 100, :months => 3)
        @termd = Factory.create(:offer_term, :price => 200, :months => 4)
        @offera.offer_terms << @terma
        @offerb.offer_terms << @termb
        @offerc.offer_terms << @termc
        @offerd.offer_terms << @termd

        @publication.reload
        @publication_with_default_set.reload

        @publication.offers.size.should == 2
        @publication_with_default_set.offers.size.should == 2

        @publication_with_default_set.offers.default_for_renewal = @offerd
        stub_wordpress
      end

      describe "and we provide publication_id" do
        it "should use the publication's default for renewal if one is set" do
          @user = Factory.create(:subscriber)
          @subscription = Factory.create(:active_subscription, :user => @user, :publication => @publication_with_default_set)
          SubscribeController.any_instance.stubs(:current_user).returns(@user)
          visit "/renew?publication_id=#{@publication_with_default_set.id}"
          page.should have_content("4 months")
        end

        it "should use the first offer available for the publication if no default is set" do
          @user = Factory.create(:subscriber)
          @subscription = Factory.create(:active_subscription, :user => @user, :publication => @publication)
          SubscribeController.any_instance.stubs(:current_user).returns(@user)
          visit "/renew?publication_id=#{@publication.id}"
          page.should have_content("1 month")
        end
      end

      describe "if the user has just one subscription" do
        it "should use the first offer available for the publication that matches the users subscription"
      end

      describe "if the user has more than one subscription" do
        it "should let them choose which subscription to renew"
      end

      it "should raise an exception if there are no offers"

      describe "and I provide my payment details" do
        it "should update my subscription"
      end
    end

    describe "and I provide an offer" do
      it "should suggest subscribing if the user has no subscriptions with the publication from the provided offer"
    end
  end
end
