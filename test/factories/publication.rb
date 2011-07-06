Factory.define :publication do |f|
  f.name { Faker::Name.name }
  f.description { Faker::Lorem.paragraph }
  f.forgot_password_link { "http://#{Faker::Internet.domain_name}/forgot_password" }
  f.custom_domain "crikey.com.au"
  f.template_name "crikey"
end

Factory.define :my_publication, :parent => :publication do |a|
  a.name 'My Publication'
end

Factory.define :powerindex_publication, :parent => :publication do |f|
  f.custom_domain "powerindex.com.au"
  f.template_name "powerindex"
end
