class OrderItem < ActiveRecord::Base
  belongs_to :gift
  belongs_to :order
end
