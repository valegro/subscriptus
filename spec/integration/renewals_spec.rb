require 'spec_helper'

describe "Renewals", :type => :integration do
  describe "when I visit the renewals page" do
    describe "and I am an admin" do
      it "I should be taken to the admin root"
    end

    describe "and no offer is set" do
      before(:each) do
        @publication = Factory.create(:publication)
        @publication_with_default_set = Factory.create(:publication)
        @offera = Factory.create(:offer, :publication => @publication)
        @offerb = Factory.create(:offer, :publication => @publication)
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

      it "should use the first offer available if none is provided" do
        @user = Factory.create(:subscriber)
        @subscription = Factory.create(:active_subscription, :user => @user, :publication => @publication)
        SubscribeController.any_instance.stubs(:current_user).returns(@user)
        visit "/renew"
        page.should have_content("1 month")
      end

      it "should raise an exception if there are no offers"
    end
  end

  # TODO: Test not showing the weekender tickbox if we already have the weekender
=begin
  describe "I visit the renewal page" do

    context "#I am not logged in" do
      it "should prompt me to login"
    end

    context "#I am logged in" do
      before(:each) do
        SubscribeController.any_instance.stubs(:current_user).with(@user)
      end

      it "should display the renewals page" do
        visit "/renew"
        page.should have_content("Renew your Subscription")
      end

      describe "and I do not modify my details" do
        visit "/renew"
        it "should NOT create a new subscription" do
          expect {
            click_link_or_button "btnSubmit"
          }.to_not change { Subscription.count }
        end

        it "should extend and activate my subscription"
        it "should display the thanks page"
      end

      describe "and I change some of my personal details" do
        before(:each) do
          fill_in "First Name", :with => "Sam"
        end

      end
    end
  end
      
  it "should create a subscription if a user has no subscriptions but tries to renew"
=end

  # TODO: Test if auth succeeds but there is no subscriptus user to match
end
__END__
  describe "when I visit the renewals page" do
    before(:each) do
        visit "/renew"
    end
    it "should be foo" do
    end

    describe "and no offer is set" do
      before(:each) do
        @publication = Factory.create(:publication)
        @publication_with_default_set = Factory.create(:publication)
        @offera = Factory.create(:offer, :publication => @publication)
        @offerb = Factory.create(:offer, :publication => @publication)
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

      it "should use the publication's default for renewal if one is set" do
        @user = Factory.create(:subscriber)
        @subscription = Factory.create(:active_subscription, :user => @user, :publication => @publication_with_default_set)
        SubscribeController.any_instance.stubs(:current_user).returns(@user)

        #visit "/renew"
        #page.should have_content("4 months")
      end

    end
  end
   
end
