Factory.define :source do |f|
  f.code { Faker::Name.name }
  f.description 'sample source' #{ Faker::Lorem.paragraph }
end
