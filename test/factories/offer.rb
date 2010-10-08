Factory.define :offer do |f|
  f.name { Faker::Name.name }
  f.trial   false # paid subscription trial
  f.publication { |p| p.association(:publication) }
end
