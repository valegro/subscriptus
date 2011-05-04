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
end
