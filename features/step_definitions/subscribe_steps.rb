When /^I fill in my details on the subscribe form$/ do
  When %{I fill in "First Name" with "Daniel"}
  And %{I fill in "Last Name" with "Draper"}
  And %{I select "The web" from "How did you hear about Crikey?"}
  And %{I fill in "Email" with "daniel@codefire.com.au"}
  And %{I fill in "Email confirmation" with "daniel@codefire.com.au"}
  And %{I fill in "Phone number" with "0403 089 661"}
  And %{I fill in "Street Address Line 1" with "That Place"}
  And %{I fill in "City" with "Adelaide"}
  And %{I select "SA" from "State"}
  And %{I fill in "Postcode" with "5000"}
  And %{I select "Australia" from "Country"}
  And %{I fill in "Password" with "Passw0rd123"}
  And %{I fill in "Password confirmation" with "Passw0rd123"}
end

When /^I fill in my Credit Card details$/ do
  When %{I select "Visa" from "Card type"}
  And %{I fill in "First name" with "Daniel"}
  And %{I fill in "Last name" with "Draper"}
  And %{I fill in "Card number" with "4444333322221111"}
  And %{I select "2011" from "subscription_payments_attributes_0_card_expiry_date_1i"}
  And %{I select "April" from "subscription_payments_attributes_0_card_expiry_date_2i"}
  And %{I fill in "Card verification" with "123"}
end

When /^the gift "(.+)" runs out of stock$/ do |gift_name|
  gift = Gift.find_by_name(gift_name)
  gift.update_attributes(:on_hand => 0)
end
