Given(/^(\d+) days? ha(?:s|ve) passed$/) do |count|
  Timecop.travel count.to_i.days.from_now
end

Given(/^(\d+) minutes? ha(?:s|ve) passed$/) do |count|
  Timecop.travel count.to_i.minutes.from_now
end

Given(/^(\d+) hours? ha(?:s|ve) passed$/) do |count|
  Timecop.travel count.to_i.hours.from_now
end

Given(/^the date is "([^"]*)"$/) do |date|
  Timecop.freeze Time.parse(date)
end


Given(/^the time is "([^"]*)"$/) do |time|
  Timecop.freeze Time.parse(time)
end

# Return to normal
After do
  Timecop.return
end