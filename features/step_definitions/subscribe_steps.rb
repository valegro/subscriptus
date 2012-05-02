When /^I fill in my details on the subscribe form$/ do
  When %{I fill in "First Name" with "Subscriptus"}
  And %{I fill in "Last Name" with "Support"}
  And %{I select "The web" from "How did you hear about Crikey?"}
  And %{I fill in "Email" with "support@subscriptus.com.au"}
  And %{I fill in "Email confirmation" with "support@subscriptus.com.au"}
  And %{I fill in "Phone number" with "03 9005 8310"}
  And %{I fill in "Street Address Line 1" with "22 William Street"}
  And %{I fill in "City" with "Melbourne"}
  And %{I select "Vic" from "State"}
  And %{I fill in "Postcode" with "3000"}
  And %{I select "Australia" from "Country"}
  And %{I fill in "Password" with "password"}
  And %{I fill in "Password confirmation" with "password"}
end

When /^I fill in my Credit Card details$/ do
  When %{I select "Visa" from "Card type"}
  And %{I fill in "First name" with "Subscriptus"}
  And %{I fill in "Last name" with "Support"}
  And %{I fill in "Card number" with "4444333322221111"}
  And %{I select "2011" from "subscription_payments_attributes_0_card_expiry_date_1i"}
  And %{I select "April" from "subscription_payments_attributes_0_card_expiry_date_2i"}
  And %{I fill in "Card verification" with "123"}
end

When /^the gift "(.+)" runs out of stock$/ do |gift_name|
  gift = Gift.find_by_name(gift_name)
  gift.update_attributes(:on_hand => 0)
end
