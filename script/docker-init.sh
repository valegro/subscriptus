#!/bin/bash

set -e

if ! mysqladmin ping 2>/dev/null; then
  mysqld_safe &

  while ! mysqladmin ping 2>/dev/null; do
    echo "waiting for mysql to start..."
    sleep 1
  done
fi

bundle exec rake db:drop || true
bundle exec rake db:create
mysql subscriptus_development < db/seeds.2013-10-18.sql

export RAILS_ENV=test
bundle exec rake db:drop || true
bundle exec rake db:create
bundle exec rake db:schema:load
unset RAILS_ENV
