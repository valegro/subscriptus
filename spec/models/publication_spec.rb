require 'spec_helper'

describe Publication do
  it "should not allow an invalid forgot_password_link" do
    publication = Factory.build(:publication, :forgot_password_link => "lame stupid data")
    lambda {
      publication.save!
    }.should raise_exception(ActiveRecord::RecordInvalid)
  end

  it "should not allow an invalid forgot_password_link" do
    publication = Factory.build(:publication)
    lambda {
      publication.save!
    }.should_not raise_exception(ActiveRecord::RecordInvalid)
  end

  describe "default renewal offers" do
    it "should load the default offer when set" do
      publication = Factory.create(:publication)
      offer1 = Factory.create(:offer, :publication => publication)
      offer2 = Factory.create(:offer, :publication => publication)
      publication.offers << offer1
      publication.offers << offer2
      publication.offers.size.should == 2

      publication.offers.default_for_renewal = offer2
      publication.offers.default_for_renewal.should be_an_instance_of(Offer)
      publication.offers.default_for_renewal.id.should == offer2.id
    end

    it "should raise if the default offer is set but is not for this publication" do
      publication = Factory.create(:publication)
      publication2 = Factory.create(:publication)
      offer1 = Factory.create(:offer, :publication => publication)
      offer2 = Factory.create(:offer, :publication => publication2)
      publication.offers << offer1
      publication2.offers << offer2

      lambda {
        publication.offers.default_for_renewal = offer2
      }.should raise_exception(Exceptions::InvalidOffer)
    end
  end
end
