#!/bin/bash

set -e

if ! mysqladmin ping 2>/dev/null; then
  mysqld_safe &

  while ! mysqladmin ping 2>/dev/null; do
    echo "waiting for mysql to start..."
    sleep 1
  done
fi

if bundle exec rake db:create; then
  mysql subscriptus_development < db/seeds.2013-10-18.sql
fi

export RAILS_ENV=test
if bundle exec rake db:create; then
  bundle exec rake db:schema:load
fi
unset RAILS_ENV
