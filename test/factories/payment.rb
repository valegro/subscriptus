Factory.define :payment do |f|
  f.card_number { '4444333322221111' }
  f.card_expiry_date { 2.years.from_now }
  f.first_name { Faker::Name.first_name }
  f.last_name { Faker::Name.last_name }
  f.amount { 100 }
  f.card_verification { '123' }
  f.card_type { 'visa' }
  f.payment_type { 'credit_card' }
  f.reference { 'Reference #12345678'}
  # f.association :subscription, :factory => :subscription
end

Factory.define :direct_debit_payment, :class => 'Payment' do |f|
  f.amount { 100 }
  f.payment_type { 'direct_debit' }
end

Factory.define :cheque_payment, :class => 'Payment' do |f|
  f.amount { 100 }
  f.payment_type { 'cheque' }
end