class Publication < ActiveRecord::Base
  include FlagShihTzu
  
  has_flags 1 => :concession, 2 => :trial, 3 => :direct_debit, 4 => :weekend_edition, :column => 'capabilities'
  
  acts_as_archive :indexes => :id
  has_many :subscriptions
  has_many :offers do
    def default_for_renewal
      Offer.find(:first, :conditions => { :id => proxy_owner.default_renewal_offer_id })
    end

    def default_for_renewal=(offer)
      unless offer.publication.id == proxy_owner.id
        raise Exceptions::InvalidOffer
      end
      proxy_owner.update_attributes!(:default_renewal_offer_id => offer.id)
    end
  end
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
  validates_format_of :from_email_address, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  default_scope :order => "name"

  named_scope :for_domain, proc { |domain| { :conditions => { :custom_domain => domain } } }

  DEFAULT_TRIAL_EXPIRY = 21 #days
end
