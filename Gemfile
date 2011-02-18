source 'http://rubygems.org'
gem "rails", "2.3.9"
gem "ruby-debug"

# Postgres support
group :postgres do
  gem 'pg'
end

group :mysql do
  gem 'mysql'
end

gem 'fastercsv'

# These are "core" gems we always use
gem 'authlogic'
gem 'searchlogic'
gem 'navigasmic'
gem 'will_paginate'
gem 'json_pure'
gem 'capistrano'

# soft delete- Hiding records instead of deleting-- acts_as_paranoid doesnt work correctly with new activerecord
gem 'acts_as_archive'

# Crontab support
gem 'whenever', :require => false

# jQuery
gem 'jrails'

# Textile user content formatting
gem 'RedCloth'

# Paperclip for attachments, plus DJ for async resizes
# http://jstorimer.com/ruby/2010/01/30/delayed-paperclip.html
#gem 'paperclip'
gem 'delayed_job', '2.0.3'
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

group :test, :cucumber, :development do
  gem 'capybara', "0.3.9"
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
#  gem 'ZenTest'
#  gem 'autotest-rails'
end
