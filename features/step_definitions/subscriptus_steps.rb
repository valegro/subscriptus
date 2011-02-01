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

