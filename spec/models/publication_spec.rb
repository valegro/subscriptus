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
end
