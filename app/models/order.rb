class Order < ActiveRecord::Base
  belongs_to :user
  has_many :order_items
  has_many :gifts, :through => :order_items, :before_add => :check_gift_on_hand, :after_add => :decrement_gift_on_hand

  validates_presence_of :user

  private
    def check_gift_on_hand(gift)
      unless gift.try(:on_hand).to_i > 0
        raise "Gift out of stock or unavailable"
      end
    end

    def decrement_gift_on_hand(gift)
      gift.decrement!(:on_hand)
    end
end
