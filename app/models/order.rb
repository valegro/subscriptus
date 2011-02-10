class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :subscription
  
  has_many :order_items
  has_many :gifts, :through => :order_items, :before_add => :check_gift_on_hand, :after_add => :decrement_gift_on_hand

  validates_presence_of :user

  named_scope :oldest_first, :order => "created_at"
  named_scope :newest_first, :order => "created_at desc"

  has_states :pending, :completed, :delayed do
    on :fulfill do
      transition :pending => :completed
      transition :delayed => :completed
    end
    on :delay do
      transition :pending => :delayed
    end
  end

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
