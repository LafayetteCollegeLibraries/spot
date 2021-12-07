#!/bin/sh

script_root="$(dirname $0)"
$script_root/wait-for.sh db:5432

if bundle exec rails db:migrate:status &> /dev/null; then
  echo "migrating databases"
  bundle exec rake db:migrate RAILS_ENV=test

  echo "migrating test database"
  bundle exec rails db:migrate
else
  bundle exec rails db:setup
  bundle exec rails db:setup RAILS_ENV=test
fi

$script_root/wait-for.sh solr:8983
$script_root/wait-for.sh fedora:8080

echo "seeding dev databases"
bundle exec rake db:seed
