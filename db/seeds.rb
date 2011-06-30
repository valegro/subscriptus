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

User.create!(:login => "netfox",
            :firstname => "netfox", 
            :lastname => "netfox", 
            :email => "admin@crikey.netfox.com", 
            :email_confirmation => "admin@crikey.netfox.com", 
            :phone_number => "netfox",
            :address_1 => "netfox",
            :city => "adelaide",
            :postcode => "5000",
            :state => :sa,
            :country => "Australia",
            :role => "admin",
            :password => "netfox",
            :password_confirmation => "netfox")
            
#<Publication id: 1, name: "Test Publication", description: "This is a test publication.", publication_image_file_name: nil, publication_image_content_type: nil, publication_image_file_size: nil, publication_image_updated_at: nil, created_at: "2011-06-30 02:43:34", updated_at: "2011-06-30 02:43:34", forgot_password_link: "http://example.com/", default_renewal_offer_id: nil> 

p = Publication.create!(
  :name => "Test Publication",
  :description => "This is a test publication.",
  :forgot_password_link => "http://example.com"
)
#<Offer id: 1, publication_id: 1, name: "Test Offer", expires: "2012-06-30 00:00:00", auto_renews: true, created_at: "2011-06-30 02:43:58", updated_at: "2011-06-30 02:43:58", trial: true, primary_offer: false> 

p.offers.create!(
  {
    :name => "Test Offer",
    :expires => Date.parse("2012-06-30 00:00:00"),
    :auto_renews => true,
    :trial => true,
    :primary_offer => false,
    :offer_terms_attributes => {
      0 => { :price => 100, :months => 12 }
    }
  }
)