class Subscription::Invoice < ActiveRecord::Base

  include Billing::Invoicer

  belongs_to :subscription

  validates_uniqueness_of :invoice_number

  default_scope :order => 'created_at desc'

  named_scope :unpaid, :conditions => { :state => 'invoiced' }

end
