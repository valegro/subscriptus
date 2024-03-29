require 'spec_helper'

describe SubscriptionAction do
  describe "class definition" do
    it { should belong_to :subscription }
    it { should belong_to :source }
    it { should have_many :subscription_gifts }
    it { should have_many :gifts }
    it { should have_one :payment }
  end

  it "should raise if apply is called without a subscription" do
    action = Factory.create(:subscription_action, :subscription => nil)
    lambda {
      action.apply
    }.should raise_error
  end
end
