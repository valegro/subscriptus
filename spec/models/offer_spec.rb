require 'spec_helper'

describe Offer do
  it "should set only one offer to primary when calling make primary!" do
    @offer1 = Factory.create(:offer)
    @offer2 = Factory.create(:offer)
    @offer1.make_primary!
    offers = Offer.find(:all, :conditions => { :primary_offer => true })
    offers.size.should == 1
    offers.first.id.should == @offer1.id
    Offer.primary_offer.id.should == @offer1.id
  end

  it "should change the primary when calling make primary!" do
    @offer1 = Factory.create(:offer)
    @offer2 = Factory.create(:offer)
    @offer1.make_primary!
    @offer2.make_primary!
    offers = Offer.find(:all, :conditions => { :primary_offer => true })
    offers.size.should == 1
    offers.first.id.should == @offer2.id
    Offer.primary_offer.id.should == @offer2.id
  end
end
