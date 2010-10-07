# Factory.define :offer, :class => Offer do |f|
#   f.publication_id        '1'
#   f.name                  'test offer'
#   f.expires               Date.today + 10
#   f.auto_renews           false
# end
# 
# Factory.define :source, :class => Source do |f|
#   f.name                  'source 1'
#   f.description           'this is source One'
#   f.code                  'srccode'
# end

Factory.define :offer do |f|
  f.name { Faker::Name.name }
  f.trial   false # paid subscription trial
  f.publication { |p| p.association(:publication) }
end

Factory.define :publication do |f|
  f.name { Faker::Name.name }
  f.description { Faker::Lorem.paragraph }
end

Factory.define :offer_term do |f|
  f.price   22
  f.months  3
  # f.price   rand(100) + 1 # 1...100
  # f.months  rand(12) + 1  # 1...12
end


Factory.define :subscription do |f|
  f.association :offer, :factory => :offer
  f.association :user, :factory => :user
  f.publication_id  1
  f.state           "trial"
  f.price           30
end

# Factory.define :credit_card, :class => Payment do |f|
#   f.first_name        'sender fname' 
#   f.last_name         'sender lname'
#   f.card_type         'visa'
#   f.card_expires_on   Date.today + 5
#   f.card_number       '4444333322221111'  # this field is not saved in db, only used to purchase
#   f.card_verification '123'               # this field is not saved in db, only used to purchase
#   f.money             200
#   f.customer_id       '123456789123457890'
# end
Factory.sequence :seq do |n|
    "#{n}"
end
Factory.define :gift do |f|
  f.name { Faker::Name.name }
  f.description { Faker::Lorem.paragraph }
  f.on_hand { rand(100) }
end
