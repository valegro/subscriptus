Given(/^the time is "([^"]*)"$/) do |time|
  Timecop.freeze Time.parse(time)
end

# Return to normal
After do
  Timecop.return
end