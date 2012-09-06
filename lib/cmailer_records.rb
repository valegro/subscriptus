class PublicationCache < Hash
  def get(name)
    if self.has_key?(name)
      self[name]
    else
      returning(Publication.find_by_name(name)) do |pub|
        self[name] = pub
      end
    end
  end
end

class OfferCache < Hash
  def get(name, publication)
    if self.has_key?(name)
      self[name]
    else
      returning(Offer.find_or_initialize_by_name(name, :publication => publication)) do |offer|
        offer.save if offer.new_record?
        if offer.offer_terms.empty?
          offer.offer_terms.create(:price => 100, :months => 3)
        end
        self[name] = offer
      end
    end
  end
end

class CmailerUser < ActiveRecord::Base
  set_table_name "users_cache"
  set_primary_key "userid"
  has_one :address, :class_name => "CmailerUserAddress", :foreign_key => "userid"
  has_many :subscriptions, :class_name => "CmailerSubscription", :foreign_key => "userid", :order => "expires_at" do
    def by_publication
      self.group_by { |s| s.publication }
    end
  end

  establish_connection(
    :adapter => "sqlserver",
    :mode => "dblib",
    :dataserver => "crikey_sql",
    :database => "cmailer",
    :username => "sa",
    :password => "zxnm()14",
    :timeout => 1000000,
    :azure => false
  )

  def save_to_subscriptus
    attrs = self.attributes.symbolize_keys
    attrs[:auto_created] = false # MUST TURN OFF validations too
    attrs[:email_confirmation] = attrs[:email]
    attrs[:password] = attrs[:password_confirmation] = "123456"
    process_title!(attrs[:title])
    if attrs[:title].blank?
      attrs.delete(:title)
    end
    attrs[:role] = 'subscriber'
    attrs[:phone_number] = attrs.delete(:phone)
    attrs.delete(:ContactId)
    attrs.delete(:userid)
    attrs.delete(:priority)

    unless self.address.blank?
      address_attributes = address.attributes
      address_attributes.delete('ContactId')
      address_attributes.delete('userid')
      address_attributes['state'] = address_attributes['state'].try(:to_s).try(:downcase!)
      address_attributes['city'] = address_attributes.delete('suburb')
      unless %w(act nsw nt qld sa tas vic wa).include?(address_attributes['state'])
        address_attributes['state'] = 'intl'
      end
      attrs.merge!(address_attributes)
    end


    returning(User.new(attrs)) do |u|
      u.save_with_validation(false)
    end
  end

  def process_title!(title)
    title.strip!
    title.capitalize!
    title.gsub!(/\./, "")
  end
end

class CmailerUserAddress < CmailerUser
  set_table_name "useraddress_cache"
  belongs_to :user, :class_name => "CmailerUser", :foreign_key => "userid"

end

class CmailerSubscription < CmailerUser
  extend ActiveSupport::Memoizable
  cattr_accessor :FYS

  set_table_name "subscriptions_cache"
  set_primary_key "userid"
  belongs_to :user, :class_name => "CmailerUser", :foreign_key => "userid"

  named_scope :not_expired, lambda { { :conditions => "expired_at not null and expired_at > #{Time.now}" }}

  @@publication_cache = PublicationCache.new
  @@offer_cache = OfferCache.new

  @@FYS = {
    "FY06" => ("2005-07-01".to_time.."2006-06-30".to_time),
    "FY07" => ("2006-07-01".to_time.."2007-06-30".to_time),
    "FY08" => ("2007-07-01".to_time.."2008-06-30".to_time),
    "FY09" => ("2008-07-01".to_time.."2009-06-30".to_time),
    "FY10" => ("2009-07-01".to_time.."2010-06-30".to_time),
    "FY11" => ("2010-07-01".to_time.."2011-06-30".to_time)
  }

  @@list_prices = {
    "Media University Subscription (Students)" => {"FY10"=>35, "FY11"=>45, "FY06"=>35, "FY07"=>35, "FY08"=>35, "FY09"=>35},
    "6 Month Subscription"                   => {"FY10"=>60, "FY11"=>60, "FY06"=>0, "FY07"=>0, "FY08"=>0, "FY09"=>0},
    "Annual Gift Subscription"               => {"FY10"=>150, "FY11"=>160, "FY06"=>100, "FY07"=>115, "FY08"=>125, "FY09"=>140},
    "Seniors/Concession Subscription"        => {"FY10"=>100, "FY11"=>110, "FY06"=>70, "FY07"=>70, "FY08"=>85, "FY09"=>95},
    "10-19 Member Group Sub"                 => {"FY10"=>85, "FY11"=>95, "FY06"=>50, "FY07"=>50, "FY08"=>60, "FY09"=>75},
    "1 Month Subscription"                   => {"FY10"=>13, "FY11"=>14, "FY06"=>13, "FY07"=>13, "FY08"=>13, "FY09"=>13},
    "Christmas 2008 2-year subscriptions"    => {"FY10"=>200, "FY11"=>200, "FY06"=>200, "FY07"=>200, "FY08"=>200, "FY09"=>200},
    "Christmas Gift Subscription"            => {"FY10"=>150, "FY11"=>160, "FY06"=>100, "FY07"=>115, "FY08"=>125, "FY09"=>140},
    "Christmas 2008 gift subscriptions"      => {"FY10"=>125, "FY11"=>125, "FY06"=>125, "FY07"=>125, "FY08"=>125, "FY09"=>125},
    "2 Year Gift Subscription"               => {"FY10"=>240, "FY11"=>260, "FY06"=>160, "FY07"=>200, "FY08"=>200, "FY09"=>225},
    "Concession Subscription"                => {"FY10"=>100, "FY11"=>110, "FY06"=>70, "FY07"=>70, "FY08"=>85, "FY09"=>95},
    "Gift Subscriptions Special Member Rate" => {"FY10"=>75, "FY11"=>79, "FY06"=>75, "FY07"=>75, "FY08"=>75, "FY09"=>75},
    "6-9 Member Group Sub"                   => {"FY10"=>95, "FY11"=>105, "FY06"=>60, "FY07"=>60, "FY08"=>70, "FY09"=>85},
    "Concession Subscription - Quarterly Payments" => {"FY10"=>27.5, "FY11"=>27.5, "FY06"=>27.5, "FY07"=>27.5, "FY08"=>27.5, "FY09"=>27.5},
    "14 Month Subscription"                  => {"FY10"=>150, "FY11"=>160, "FY06"=>100, "FY07"=>115, "FY08"=>125, "FY09"=>140},
    "Student Subscription"                   => {"FY10"=>100, "FY11"=>110, "FY06"=>70, "FY07"=>70, "FY08"=>85, "FY09"=>95},
    "6-Week Free Subscription"               => {"FY10"=>0, "FY11"=>0, "FY06"=>0, "FY07"=>0, "FY08"=>0, "FY09"=>0},
    "13 Month Subscription"                  => {"FY10"=>150, "FY11"=>160, "FY06"=>100, "FY07"=>115, "FY08"=>125, "FY09"=>140},
    "50+ Group Subscription"                 => {"FY10"=>65, "FY11"=>75, "FY06"=>35, "FY07"=>35, "FY08"=>40, "FY09"=>55},
    "20-49 Member Group Sub"                 => {"FY10"=>75, "FY11"=>85, "FY06"=>40, "FY07"=>40, "FY08"=>50, "FY09"=>65},
    "Christmas 2009 Gift Subscription"       => {"FY10"=>140, "FY11"=>140, "FY06"=>140, "FY07"=>140, "FY08"=>140, "FY09"=>140},
    "4 Month Christmas Gift Subscription"    => {"FY10"=>50, "FY11"=>50, "FY06"=>50, "FY07"=>50, "FY08"=>50, "FY09"=>50},
    "Media University Subscription (Lecturers)" => {"FY10"=>65, "FY11"=>75, "FY06"=>65, "FY07"=>65, "FY08"=>65, "FY09"=>65},
    "3-5 Member Group Sub"                   => {"FY10"=>105, "FY11"=>115, "FY06"=>70, "FY07"=>70, "FY08"=>80, "FY09"=>95},
    "2 Year Subscription"                    => {"FY10"=>240, "FY11"=>260, "FY06"=>160, "FY07"=>200, "FY08"=>200, "FY09"=>225},
    "Annual Subscription"                    => {"FY10"=>150, "FY11"=>160, "FY06"=>100, "FY07"=>115, "FY08"=>125, "FY09"=>140},
    "3 Month Subscription"                   => {"FY10"=>0, "FY11"=>33, "FY06"=>0, "FY07"=>0, "FY08"=>0, "FY09"=>0}
  }

  def inspect
    return <<-STR
      state:                      #{state}
      created_at:                 #{created_at}
      expires_at:                 #{expires_at}
      subscription_date_created:  #{subscription_date_created}
      publication:                #{publication.try(:name)}
      offer:                      #{offer.try(:name)}
      list:                       #{list}
    STR
  end

  def save_to_subscriptus(user)
    attrs = attributes.symbolize_keys
    _offer = offer
    pending_action = if state == 'pending'
      # Create a pending action
      SubscriptionAction.new do |act|
        act.offer_name = _offer.name
        act.term_length = _offer.offer_terms.first # TODO: Is this right? Should be getting it from the offer or list name?
        act.payment = Payment.new(:payment_type => 'direct_debit', :amount => self.price)
      end
    end
    subscription = Subscription.new(
      :user          => user,
      :state         => state,
      :price         => attrs[:price],
      :created_at    => attrs[:created_at],
      :expires_at    => attrs[:expires_at],
      :offer         => _offer,
      :publication   => publication,
      :pending_action => pending_action,
      :pending       => state == 'pending' ? 'payment' : nil
    )
    subscription.save_with_validation(false)
    # Suspension dates
    if state == 'suspended'
      subscription.update_attributes(
        :state_updated_at => self.SuspendFrom,
        :state_expires_at => self.SuspendTo
      )
      subscription.save_with_validation(false)
    end
    # Action
    action = SubscriptionAction.new(
      :subscription => subscription,
      :offer_name => _offer.name,
      :term_length => _offer.offer_terms.first.months,
      :applied_at => attrs[:created_at]
    )
    action.save_with_validation(false)
    # Payment
    unless self.PurchaseOrderNumber.blank?
      payment = action.build_payment(
        :amount => self.price,
        :reference => self.PurchaseOrderNumber,
        :payment_type => :historical,
        :processed_at => self.created_at
      )
      payment.save_with_validation(false)
    end
  end

  def publication
    name = read_attribute(:publication).try(:strip)
    # Ignore the record if it has no publication
    return nil if name.blank?
    @@publication_cache.get(name)
  end

  def state
    read_attribute(:state).strip.downcase
  end

  def statusname
    read_attribute(:statusname).strip
  end

  def source
    read_attribute(:source).strip
  end

  def offer
    name = read_attribute(:offer).strip
    name = "Unknown Offer" if name.blank?
    return nil if publication.blank?
    @@offer_cache.get(name, publication)
  end

  def list
    read_attribute(:list).try(:strip)
  end

  def price
    # Find FY
    pair = @@FYS.select do |fy, range|
      range.include?(self.created_at)
    end
    return 0 unless pair
    fy = pair[0].try(:[], 0)
    @@list_prices[list].try(:[], fy) || 0
  end

  memoize :offer, :publication, :price

  private
    def set_status(status)
      case status
        when 'Active' then 'active'
        when 'Expired', 'Unsubscribed' then 'squatter'
        when 'Suspended' then 'suspended'
      end
    end
end



