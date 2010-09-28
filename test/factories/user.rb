Factory.define :user do |u|
  u.email         { @email= "email_#{Factory.next(:seq)}@example.com" }
  u.email_confirmation { @email }
  u.login { "login_#{Factory.next(:seq)}" }
  u.password "password"
  u.password_confirmation { |x| x.password }
  u.firstname { "firstname_#{Factory.next(:seq)}" }
  u.lastname { "lastname_#{Factory.next(:seq)}" }
  u.phone_number '12345678'
  u.address_1 '1 1st street'
  u.city 'Camelot'
  u.postcode '1234 '
  u.state "SA"
  u.country "Sealand"
end

