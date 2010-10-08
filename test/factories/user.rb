Factory.define :user do |f|
  # f.id                      1
  f.login                    { Faker::Name.first_name }
  f.password                'password122'
  f.password_confirmation   'password122'
  f.firstname { Faker::Name.first_name }
  f.lastname { Faker::Name.last_name }
  f.email                   'sample@sample.com'
  f.email_confirmation      'sample@sample.com'
  f.phone_number { Faker::PhoneNumber.phone_number }
  f.address_1 { Faker::Address.street_address }
  f.postcode { Faker::Address.zip_code }
  f.city { Faker::Address.city }
  f.state                   'SA'
  f.country                 'Australia'
end
