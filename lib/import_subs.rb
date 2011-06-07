require 'csv'

a = 0 #users_that_exist = 0
b = 0 #users_that_exist_but_no_pub = 0
c = 0 #users_that_exist_but_no_pub_and_cmailer_state_is_future = 0
d = 0 #users_that_do_not_exist = 0
e = 0 #users_that_do_not_exist_but_and_cmaile_state_is_future = 0

def create_action(subscription, starts_at, expires_at, payment_at, offer_name)
  begin
    term_length = ((DateTime.strptime(expires_at, '%d/%m/%Y %H:%M') - DateTime.strptime(starts_at, '%d/%m/%Y %H:%M'))/30).to_i
    # First clear any actions made today - not nec unless we are running several times
    #subscription.actions.find(:all, :conditions => "applied_at > '2011-06-07 16:00'").each(&:delete)
    subscription.actions.create!(
      :offer_name => offer_name,
      :applied_at => DateTime.strptime(payment_at, '%d/%m/%Y %H:%M'),
      :term_length => term_length
    )
  rescue
    puts $!
    puts "expires_at = #{expires_at.inspect}, starts_at = #{starts_at.inspect}"
  end
end

CSV.foreach(ARGV[0]) do |row|
  publication_name = row[0]
  offer_id    = row[1]
  payment_at  = row[2]
  cmailer_state = row[4]
  starts_at     = row[5]
  expires_at    = row[6]

  user_attributes = {
    :title         => row[7].try(:strip).try(:gsub, /\./, '') || 'Mr',
    :firstname     => row[8].try(:strip),
    :lastname      => row[9].try(:strip),
    :email         => row[10].try(:strip),
    :address_1     => row[11].try(:strip) || 'Not Provided',
    :address_2     => row[12].try(:strip),
    :city          => row[13].try(:strip) || 'Not Provided',
    :state         => row[14].try(:strip).try(:downcase),
    :postcode      => row[15].try(:strip) || '2000',
    :country       => row[16].try(:strip),
    :company       => row[17].try(:strip),
    :phone_number  => "Not Provided"
  }

  if user_attributes[:state] == 'other'
    user_attributes[:state] = 'intl'
  end

  offer = Offer.find(offer_id)

  # Look up user with email
  user = User.find_by_email(user_attributes[:email])
  # User exists
  if user
    a += 1
    # Update the user's attributes
    begin
      user.update_attributes!(user_attributes)
    rescue
      puts $!
      p user_attributes
      raise $!
    end
    # Do they have a DailyMail subscription?
    publication = Publication.find_by_name(publication_name)
    raise "No such publication #{publication_name}" unless publication
    subscription = user.subscriptions.find(:first, :conditions => { :publication_id => publication.id })

    if subscription
      # Extend/activate depending on state
      subscription.state       = 'active'
      subscription.expires_at  = DateTime.strptime(expires_at, '%d/%m/%Y %H:%M')
      subscription.offer_id    = offer_id
      subscription.save!
      create_action(subscription, starts_at, expires_at, payment_at, offer.name)
    else
      b += 1
      c += 1 if cmailer_state =~ /started/i
      # Create a subscription to Daily Mail
      subscription = user.subscriptions.create!(
        :publication => publication,
        :offer_id => offer_id,
        :state => 'active',
        :expires_at => DateTime.strptime(expires_at, '%d/%m/%Y %H:%M')
      )
      create_action(subscription, starts_at, expires_at, payment_at, offer.name)
    end
  else
    d += 1
    e += 1 if cmailer_state =~ /started/i
    puts "Email of missing user = #{user_attributes[:email]}"
    # Create a User and subscribe them to the Daily Mail
=begin
    user = User.new(user_attributes)
    user.save_with_validation(false)
    user.subscriptions.create(
      :publication => publication,
      :offer_id => offer_id,
      :state => 'active',
      :expires_at => expires_at
    )
    create_action(subscription, starts_at, expires_at, payment_at, offer.name)
=end
  end
end

puts "users_that_exist = #{a}"
puts "users_that_exist_but_no_pub = #{b}"
puts "users_that_exist_but_no_pub_and_cmailer_state_is_future = #{c}"
puts "users_that_do_not_exist = #{d}"
puts "users_that_do_not_exist_but_and_cmaile_state_is_future = #{d}"
