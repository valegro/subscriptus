class Source < ActiveRecord::Base
  has_many :subscription_log_entries
  validates_presence_of :code, :description
  default_scope :order => "code"
end
