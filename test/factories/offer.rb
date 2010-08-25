Factory.define :offer do |f|
  f.name { Faker::Name.name }
  f.publication { |p| p.association(:publication) }
end
