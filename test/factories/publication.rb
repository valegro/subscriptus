Factory.define :publication do |f|
  f.name { Faker::Name.name }
  f.description { Faker::Lorem.paragraph }
  f.forgot_password_link { "http://#{Faker::Internet.domain_name}/forgot_password" }
  f.custom_domain {Factory.next(:domain)}
  f.from_email_address { |x| "no-reply@#{x.custom_domain}" } 
  f.template_name "crikey"
end

Factory.sequence :domain do |n|
  "#{n}.crikey.com.au"
end

Factory.define :my_publication, :parent => :publication do |a|
  a.name 'My Publication'
end

Factory.define :powerindex_publication, :parent => :publication do |f|
  f.custom_domain "powerindex.com.au"
  f.template_name "powerindex"
  f.from_email_address "no-reply@powerindex.com.au"
end
