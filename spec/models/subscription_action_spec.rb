require 'spec_helper'

describe SubscriptionAction do
  describe "class definition" do
    it { should belong_to :subscription }
    it { should belong_to :source }
    it { should have_many :subscription_gifts }
    it { should have_many :gifts }
  end
end
