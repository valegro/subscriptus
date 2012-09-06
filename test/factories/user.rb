Factory.define :user do |f| # Dont use this factory. Use either an admin or a subscriber instead
  f.firstname { Faker::Name.first_name }
  f.lastname { Faker::Name.last_name }
  f.email { @email= Faker::Internet.email }
  f.email_confirmation { |x| x.email }
  f.password "password"
  f.password_confirmation { |x| x.password }
  f.phone_number { Faker::PhoneNumber.phone_number }
  f.address_1 { Faker::Address.street_address }
  f.postcode { Faker::Address.zip_code }
  f.city { Faker::Address.city }
  f.state :sa
  f.title :Mr
  f.country 'Australia'
  f.role 'subscriber'
end

Factory.define :admin, :parent => :user do |a|
  a.login { Faker::Name.name.downcase }
  a.role { 'admin' }
end

Factory.define :admin_attributes, :class => User do |a|
  a.firstname { Faker::Name.first_name }
  a.lastname { Faker::Name.last_name }
  a.email { @email= Faker::Internet.email }
  a.email_confirmation { |x| x.email }
  a.password "password"
  a.password_confirmation { |x| x.password }
  a.login { Faker::Name.name.downcase }
  a.role { 'admin' }
end

Factory.define :subscriber, :parent => :user do |a|
  a.role { 'subscriber' }
end

Factory.define :user_with_token, :parent => :user do |a|
  a.payment_gateway_token { '1234567' }
end
