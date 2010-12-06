require 'spec_helper'

describe Order do
  before(:each) do
    @user = Factory(:user)
  end

  it "should decrement the gift on hand count" do
    @gift = Factory(:gift, :on_hand => 20)
    @order = Order.new(:user => @user)
    @order.gifts << @gift
    @order.save
    @gift.on_hand.should == 19
  end

  it "should not be valid if gift out of stock" do
    @gift = Factory(:gift, :on_hand => 0)
    @order = Order.create(:user => @user)
    lambda {
      @order.gifts << @gift
    }.should raise_exception
    @order.gifts.size.should == 0
    @gift.on_hand.should == 0
  end
end
