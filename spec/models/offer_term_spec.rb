require 'spec_helper'

describe OfferTerm do
  before(:each) do
    @offer = Factory.create(:offer)
  end

  it "should deny two terms of the same length and concession state" do
    @offer.offer_terms << Factory.create(:offer_term, :months => 1)
    @offer.offer_terms.size.should == 1
    @offer.offer_terms << Factory.create(:offer_term, :months => 1)
    @offer.offer_terms.size.should == 1
  end

  it "should allow two terms of the same length if one is a concession term" do
    @offer.offer_terms << Factory.create(:offer_term, :months => 1)
    @offer.offer_terms.size.should == 1
    @offer.offer_terms << Factory.create(:offer_term, :months => 1, :concession => true)
    @offer.offer_terms.size.should == 2
  end

  it "should allow two terms of the same length if they apply to different offers" do
    @offer2 = Factory.create(:offer)
    @offer.offer_terms << Factory.create(:offer_term, :months => 1)
    @offer.offer_terms.size.should == 1
    @offer2.offer_terms << Factory.create(:offer_term, :months => 1)
    @offer2.offer_terms.size.should == 1
    OfferTerm.count.should == 2
  end

end
