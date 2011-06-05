require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::SubscribersController, "as admin" do
  before(:each) do
    stub_wordpress
    admin_login
  end

  describe "on update" do
    before(:each) do
      @subscriber = Factory.create(:subscriber)
    end

    describe "given that wordpress will raise an error" do
      before(:each) do
        Wordpress.expects(:make_request).raises(Wordpress::Error, "Test Error")
        Admin::SubscribersController.any_instance.expects(:notify_hoptoad).with(instance_of(Wordpress::Error))
      end

      it "should show the edit page with the error in the flash" do
        post(:update, :id => @subscriber.id)
        response.should render_template("edit")
        flash[:error].should == "Wordpress Error: Test Error"
      end
    end
  end
end
