# Used for exact == matches (not regexes)
Then /^the "([^"]*)" field(?: within "([^"]*)")? should be exactly "([^"]*)"$/ do |field, selector, value|
  with_scope(selector) do
    field = find_field(field)
    field_value = (field.tag_name == 'textarea') ? field.text : field.value
    assert_match("#{value}", field_value)
  end
end


