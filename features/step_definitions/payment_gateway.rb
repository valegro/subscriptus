Before do
  gw_response = stub(:success? => true)
  GATEWAY.expects(:purchase).returns(gw_response)
end

Given /^my Credit Card will decline$/ do
  gw_response = stub(:success? => false, :message => "Test Failure")
  GATEWAY.expects(:purchase).returns(gw_response)
end

Given /^my Credit Card will succeed$/ do
  gw_response = stub(:success? => true)
  GATEWAY.expects(:purchase).returns(gw_response)
end

Given /^my token payment will succeed$/ do
  gw_response = stub(:success? => true)
  GATEWAY.expects(:trigger_recurrent).returns(gw_response)
end
