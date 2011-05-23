require 'CSV'

CSV.open('users.csv', 'r') do |csv|
  login, email = csv
  User.update_all "login = E'#{login}'", "email = E'#{email}'"
end
