Factory.define :subscription do |f|
  f.user_id         1
  f.offer_id        1
  f.publication_id  1
  f.state           "trial"
  f.price           30
end
