Factory.define :user do |f| # Dont use this factory. Use either an admin or a subscriber instead
  f.login { Faker::Name.first_name }
  f.firstname { Faker::Name.first_name }
  f.lastname { Faker::Name.last_name }
  f.email { @email= Faker::Internet.email }
  f.email_confirmation { @email }
  f.password "password"
  f.password_confirmation { |x| x.password }
  f.phone_number { Faker::PhoneNumber.phone_number }
  f.address_1 { Faker::Address.street_address }
  f.postcode { Faker::Address.zip_code }
  f.city { Faker::Address.city }
  f.state 'SA'
  f.country 'Australia'
end

Factory.define :admin, :parent => :user do |a|
  a.role { 'admin' }
end

Factory.define :subscriber, :parent => :user do |a|
  a.role { 'subscriber' }
end
