source 'http://rubygems.org'
gem "rails", "2.3.9"
gem "ruby-debug"

gem "rake", "0.9.2"

# Postgres support
#group :postgres do
  gem 'pg'
#end

group :production do
  gem 'mysql'
end

gem 'fastercsv'
gem 'rest-client'

gem 'rack', '1.1.0'

# These are "core" gems we always use
gem 'authlogic'
gem 'searchlogic'
gem 'navigasmic'
gem 'will_paginate', "2.3.15"
gem 'json_pure'
gem 'capistrano'

gem 'hoptoad_notifier'

# Used for Data Migration
gem 'activerecord-sqlserver-adapter'
# gem 'tiny_tds'

# soft delete- Hiding records instead of deleting-- acts_as_paranoid doesnt work correctly with new activerecord
# Use this fork because the mover gem doesn't work with Postgres :(
gem 'mover', :git => 'git://github.com/codefire/mover.git'
# Use this fork because of https://github.com/winton/acts_as_archive/pull/18
gem 'acts_as_archive', :git => 'git://github.com/comboy/acts_as_archive.git'

# Crontab support
gem 'whenever', :require => false

# jQuery
gem 'jrails'

# Textile user content formatting
gem 'RedCloth'

# Paperclip for attachments, plus DJ for async resizes
# http://jstorimer.com/ruby/2010/01/30/delayed-paperclip.html
#gem 'paperclip'
gem 'delayed_job', '2.0.7'
gem 'delayed_paperclip'

gem 'mechanize'

# Needed for Campaign Master
gem 'httpclient'
gem 'soap4r'

# Others
gem 'aws-s3', :require => "aws/s3"
gem 'wizardly'
gem 'enumerated_attribute'

gem 'ruby-debug'

gem 'liquid'
gem 'domainatrix'

group :development, :test, :cucmber do
  gem 'pg'
  gem 'webmock', :require => false
  gem 'selenium-webdriver', '2.0.1'
  gem 'capybara', "0.4.1.2"
  gem 'database_cleaner'
  gem 'spork'
  gem 'launchy'    # So you can do Then show me the page
  gem 'cucumber', "0.8.5"
  gem 'cucumber-rails'
  gem 'pickle'
  gem 'factory_girl'
  gem 'faker'
  gem 'shoulda'
  gem 'gherkin'
  gem 'rack-test', "0.5.4"
  gem 'rspec', '1.3.1'
  gem 'rspec-rails', '1.3.3'
  gem 'mocha', '~> 0.9.8'
  gem 'timecop'
  gem 'akephalos'
  gem 'ruby-prof'
end
