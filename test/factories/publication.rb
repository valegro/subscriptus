Factory.define :publication do |f|
  f.name { Faker::Name.name }
  f.description { Faker::Lorem.paragraph }
  f.forgot_password_link { "http://#{Faker::Internet.domain_name}/forgot_password" }
end

Factory.define :my_publication, :parent => :publication do |a|
  a.name 'My Publication'
end
