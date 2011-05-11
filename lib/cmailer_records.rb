class CmailerUser < ActiveRecord::Base
  set_table_name "users"
  set_primary_key "ContactId"
  has_many :subscriptions, :class_name => "CmailerSubscription", :foreign_key => "ContactId", :order => "expires_at" do
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
    attrs[:state].downcase!
    attrs[:auto_created] = true
    attrs[:email_confirmation] = attrs[:email]
    attrs[:password] = attrs[:password_confirmation] = "123456"
    process_title!(attrs[:title])
    if attrs[:title].blank?
      attrs.delete(:title)
    end
    attrs[:role] = 'subscriber'
    attrs[:phone_number] = attrs.delete(:phone)
    attrs.delete(:ContactId)

    unless %w(act nsw nt qld sa tas vic wa).include?(attrs[:state].to_s)
      attrs[:state] = 'intl'
    end

    User.create!(attrs)
  end

  def process_title!(title)
    title.strip!
    title.capitalize!
    title.gsub!(/\./, "")
  end
end

class CmailerSubscription < CmailerUser
  set_table_name "subscriptions"
  set_primary_key "ContactId"
  belongs_to :user, :class_name => "CmailerUser"

  named_scope :not_expired, lambda { { :conditions => "expired_at not null and expired_at > #{Time.now}" }}

  def inspect
    return <<-STR
      state:        #{state}
      created_at:   #{created_at}
      expires_at:   #{expires_at}
      publication:  #{publication.try(:name)}
      offer:        #{offer.try(:name)}
      list:         #{list}
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
    subscription = Subscription.create!(
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
    SubscriptionAction.create!(
      :subscription => subscription,
      :offer_name => _offer.name,
      :term_length => _offer.offer_terms.first.months,
      :applied_at => attrs[:created_at]
    )
    # TODO: Payment?
  end

  def publication
    name = read_attribute(:publication).try(:strip)
    if name.blank?
      name = (list == 'Crikey Weekender') ? list : 'Crikey Daily Mail'
    end
    Publication.find_by_name(name)
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
    returning(Offer.find_or_initialize_by_name(name, :publication => publication)) do |offer|
      offer.save! if offer.new_record?
      if offer.offer_terms.empty?
        offer.offer_terms.create(:price => 100, :months => 3)
      end
    end
  end

  def list
    read_attribute(:list).try(:strip)
  end

  private
    def find_publication(name)
    end

    def set_status(status)
      case status
        when 'Active' then 'active'
        when 'Expired', 'Unsubscribed' then 'squatter'
        when 'Suspended' then 'suspended'
      end
    end
end


