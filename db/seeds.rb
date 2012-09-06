# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)
#FIXME
User.destroy_all
Publication.destroy_all
Offer.destroy_all

User.create!(:login => "admin",
            :firstname => "Subscriptus", 
            :lastname => "Administrator", 
            :email => "admin@subscriptus.co", 
            :email_confirmation => "admin@subscriptus.co", 
            :phone_number => "03 90187510",
            :address_1 => "Subscriptus",
            :city => "subscriptus",
            :postcode => "5000",
            :state => :sa,
            :country => "Australia",
            :role => "admin",
            :password => "netfox",
            :password_confirmation => "netfox")
            
crikey = Publication.create!(
  :name => "Crikey!",
  :description => "This is a test publication.",
  :forgot_password_link => "http://example.com",
  :custom_domain => "crikey.dev",
  :template_name => "crikey",
  :concession => true,
  :trial => true,
  :direct_debit => true,
  :weekend_edition => true,
  :terms_url => 'http://www.crikey.com.au/about/terms-conditions/'
  
)
crikey.offers.create!(
  {
    :name => "Crikey Offer",
    :expires => Date.parse("2012-06-30 00:00:00"),
    :auto_renews => true,
    :trial => true,
    :primary_offer => false,
    :offer_terms_attributes => {
      0 => { :price => 100, :months => 12 }
    }
  }
)

powerindex = Publication.create!(
  :name => "The Power Index",
  :description => "This is a test publication.",
  :forgot_password_link => "http://example.com",
  :custom_domain => "powerindex.dev",
  :template_name => "powerindex",
  :terms_url => 'http://www.thepowerindex.com.au/terms-and-conditions'
  
)
powerindex.offers.create!(
  {
    :name => "The Power Index Offer",
    :expires => Date.parse("2012-06-30 00:00:00"),
    :auto_renews => true,
    :trial => true,
    :primary_offer => false,
    :offer_terms_attributes => {
      0 => { :price => 100, :months => 12 }
    }
  }
)
