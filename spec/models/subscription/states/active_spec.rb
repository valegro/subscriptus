require 'spec_helper'

# TODO: Much more here!!
describe Subscription do

  before(:each) do
    today = Date.new(2010, 9, 27) # today is "Mon, 27 Sep 2010"
    Date.stubs(:today).returns(today)
    stub_wordpress
  end

  # TODO: Move this to active_spec.rb
  describe "upon expire!" do
    before(:each) do
      @subscription = Factory.create(:subscription, :state => 'active')
    end

    it "should create a log entry" do
      @subscription.log_entries.size.should == 1
      @subscription.expire!
      @subscription.log_entries.size.should == 2
      entry = @subscription.log_entries.last
      entry.new_state.should == 'squatter'
    end

    it "should deliver an email" do
      pending
    end
  end

end
