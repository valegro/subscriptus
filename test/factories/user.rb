Factory.define :user do |f|
  # f.id                      1
  f.login                    { Faker::Name.first_name }
  f.firstname { Faker::Name.first_name }
  f.lastname { Faker::Name.last_name }
  f.email         { @email= "email_#{Factory.next(:seq)}@example.com" }
  f.email_confirmation { @email }
  f.password "password"
  f.password_confirmation { |x| x.password }
  f.phone_number { Faker::PhoneNumber.phone_number }
  f.address_1 { Faker::Address.street_address }
  f.postcode { Faker::Address.zip_code }
  f.city { Faker::Address.city }
  f.state                   'SA'
  f.country                 'Australia'
end

Factory.define :admin, :parent => :user do |a|
  a.role { 'admin' }
end

Factory.define :subscriber, :parent => :user do |a|
  a.role { 'subscriber' }
end

