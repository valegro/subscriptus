# Used for exact == matches (not regexes)
Then /^the "([^"]*)" field(?: within "([^"]*)")? should be exactly "([^"]*)"$/ do |field, selector, value|
  with_scope(selector) do
    field = find_field(field)
    field_value = (field.tag_name == 'textarea') ? field.text : field.value
    assert_match("#{value}", field_value)
  end
end

When /^I select "([^"]*)" as the "([^"]*)" date$/ do |value, field|
  select_date(field, :with => value)
end

def select_date(field, options = {})
  field_id = find_id(field)
  date = Date.parse(options[:with])
  select(date.year.to_s, :from => "#{field_id}_1i" )
  select(date.strftime('%B'), :from => "#{field_id}_2i" )
  select(date.day.to_s, :from => "#{field_id}_3i" )
end

def find_id(field)
  find(:xpath, "//label[contains(.,'#{field}')]").try(:[],:for) || field
end


Given(/^#{capture_model} has been deleted$/) do |name|
  model!(name).delete
end

Given(/^#{capture_model} has been destroyed$/) do |name|
  model!(name).destroy!
end

Then /^the "([^"]*)" field(?: within "([^"]*)")? should be a url with path "([^"]*)"$/ do |field, selector, url|
  with_scope(selector) do
    field = find_field(field)
    field_value = (field.tag_name == 'textarea') ? field.text : field.value
    url_value = URI.parse(field_value).request_uri
    if field_value.respond_to? :should
      url_value.should == url
    else
      assert_match(url, url_value)
    end
  end
end

Then /^the "([^"]*)" field(?: within "([^"]*)")? should be a url: "([^"]*)"$/ do |field, selector, url|
  with_scope(selector) do
    field = find_field(field)
    field_value = (field.tag_name == 'textarea') ? field.text : field.value
    url_value = URI.parse(field_value).to_s
    if field_value.respond_to? :should
      url_value.should == url
    else
      assert_match(url, url_value)
    end
  end
end
