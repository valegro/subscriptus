class Publication < ActiveRecord::Base
  has_many :subscriptions
  has_many :offers
  has_many :subscription_log_entries
  has_attached_file :publication_image,
    :styles => { :medium => "350x350>", :thumb => "100x100>" },
    :storage => :s3,
    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
    :path => ":attachment/:id/:style.:extension",
    :bucket => 'crikeystaging'

  validates_presence_of :name, :description
  validates_uniqueness_of :name
  default_scope :order => "name"
end
