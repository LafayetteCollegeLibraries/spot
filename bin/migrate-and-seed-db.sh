#!/bin/sh

script_root="$(dirname $0)"
$script_root/wait-for.sh db:5432

echo "migrating test database"
bundle exec rake db:migrate RAILS_ENV=test

echo "migrating dev database"
bundle exec rake db:migrate

$script_root/wait-for.sh solr:8983
$script_root/wait-for.sh fedora:8080

echo "seeding dev databases"
bundle exec rake db:seed
