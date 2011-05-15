class Publication < ActiveRecord::Base
  acts_as_archive :indexes => :id
  has_many :subscriptions
  has_many :offers
  has_many :subscription_log_entries
  has_attached_file :publication_image,
    :styles => { :medium => "350x350>", :thumb => "100x100>" },
    :storage => :s3,
    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
    :path => ":attachment/:id/:style.:extension",
    :bucket => 'crikeystaging'

  validates_presence_of :name, :description, :forgot_password_link
  validates_uniqueness_of :name
  validates_format_of :forgot_password_link, :with => URI::regexp(%w(http https))
  default_scope :order => "name"

  DEFAULT_TRIAL_EXPIRY = 21 #days
end
