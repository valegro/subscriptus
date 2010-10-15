Factory.define :publication do |f|
  f.name { Faker::Name.name }
  f.description { Faker::Lorem.paragraph }
end

Factory.define :my_publication, :parent => :publication do |a|
  a.name 'My Publication'
end
