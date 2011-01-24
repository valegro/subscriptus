# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)
#FIXME
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