Factory.define :user do |f|
  f.firstname { Faker::Name.first_name }
  f.lastname { Faker::Name.last_name }
  f.login { Faker::Internet.user_name }
  f.email { "foo@example.com" }
  f.email_confirmation { "foo@example.com" }
  f.title { 'Mr' }
  f.password { "password"}
  f.password_confirmation { "password" }
  f.phone_number { '1234' }
  f.address_1 { 'That Place' }
  f.city { 'Adelaide' }
  f.postcode { '5000' }
  f.state { 'SA' }
  f.country { 'Australia' }
end

Factory.define :admin, :parent => :user do |a|
  a.role { 'admin' }
end

Factory.define :subscriber, :parent => :user do |a|
  a.role { 'subscriber' }
end
