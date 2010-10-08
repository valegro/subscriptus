Factory.define :gift do |f|
  f.name { Faker::Name.name }
  f.description { Faker::Lorem.paragraph }
  f.on_hand { rand(100) }
end