# http://makandra.com/notes/763-cucumber-step-to-match-table-rows-with-capybara

Then /^I should see the following table rows( in any order)?:?$/ do |unordered, expected_table|
  document = Nokogiri::HTML(page.body)
  rows = document.xpath('//table//tr').collect { |row| row.xpath('.//th|td') }
  expected_table = expected_table.raw
  expected_table.all? do |expected_row|
    first_row = rows.find_index do |row|
      expected_row.all? do |expected_column|
        first_column = row.find_index do |column|
          content = column.content.gsub(/[\r\n\t]+/, ' ').gsub(/[ ]+/, ' ').strip
          content.include? expected_column.gsub('  ', ' ').strip
        end
        if first_column.nil?
          false
        else
          row = row[(first_column + 1)..-1]
          true
        end
      end
    end
    if first_row.nil?
      false
    else
      if unordered
        rows.delete_at(first_row)
      else
        rows = rows[(first_row + 1)..-1]
      end
      true
    end
  end.should be_true
end

Then(/^I should see the following "([^"]*)" table:$/) do |table_id, table|
  # table.diff!(tableish("table tr", "th,td"))
  #with_scope("##{table_id}") do
    Then "I should see the following table rows:", table
  #end
end

