class Subscription::Payment < ActiveRecord::Base

  named_scope :successfull, :conditions => { :success => true }
  named_scope :failed, :conditions => { :success => false }

  belongs_to :invoice, :class_name => "::Subscription::Invoice", :foreign_key => :subscription_invoice_id
  belongs_to :subscription

  default_scope :order => 'created_at desc'

  def amount_in_dollars
    (self.amount / 100.00)
  end

end
