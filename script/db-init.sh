#!/bin/bash

if bundle exec rake db:create; then
  mysql -u root subscriptus_development < db/seeds.2013-10-18.sql
fi

export RAILS_ENV=test
if bundle exec rake db:create; then
  bundle exec rake db:migrate
fi
unset RAILS_ENV
