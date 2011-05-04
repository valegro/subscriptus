class CmailerUser < ActiveRecord::Base
  set_table_name "users"
  set_primary_key "ContactId"

  establish_connection(
    :adapter  => "mysql",
    :host     => "localhost",
    :username => "root",
    :password => 'zxnm9014',
    :database => "cmailer",
    :port     => 3306,
    :socket   => "/tmp/mysql.sock"
  )

  def attributes
    JSON.parse(self.user)
  end

  def save_model
    attrs = attributes.symbolize_keys
    attrs[:role] = 'subscriber'
    attrs[:title].capitalize! # TODO: Handle titles that aren't in the enumeration
    attrs[:state].downcase!
    attrs[:password] = attrs[:password_confirmation] = "123456"
    attrs[:email_confirmation] = attrs[:email]
    attrs[:auto_created] = true
    p attrs
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

  def attributes
    JSON.parse(self.subscriptions)
  end

  def save_model(user)
    attrs = attributes.symbolize_keys
    offer = find_offer(attrs[:offer])
    subscription = Subscription.create!(
      :user          => user,
      :state         => set_status(attrs[:state]),
      :price         => attrs[:price],
      :created_at    => attrs[:created_at],
      :expires_at    => attrs[:expires_at],
      :offer         => offer,
      :publication   => find_publication(attrs[:publication])
    )
    SubscriptionAction.create!(
      :subscription => subscription,
      :offer_name => offer.name,
      :term_length => offer.offer_terms.first.months,
      :applied_at => attrs[:created_at]
    )
    # TODO: Payment?
  end

  private
    def find_offer(name)
      Offer.find_by_name(name.strip)
    end

    def find_publication(name)
      Publication.find_by_name(name.strip)
    end

    def set_status(status)
      case status
        when 'Active' then 'active'
        when 'Expired', 'Unsubscribed' then 'squatter'
        when 'Suspended' then 'suspended'
      end
    end
end

errors = 0
CmailerSubscription.find_each(:batch_size => 100) do |cm_subscription|
  begin
    CmailerUser.transaction do
      cm_user = CmailerUser.find(cm_subscription.ContactId)
      user = cm_user.save_model
      cm_subscription.save_model(user)
    end
  rescue
    puts "\n\nError #{$!}"
    puts "--------"
    puts cm_subscription.inspect
    puts "--------"
    errors += 1
  end
end

puts "Errors: #{errors}"

# TODO: INdex subscriptions and users
# TODO: Ensure we are using InnoDB

# Merge phone_number, workphone
# Add mobile?
# login?
# How do we link to WP?
