#!/bin/bash

script_root="$(dirname $0)"

$script_root/wait-for.sh db:5432
$script_root/wait-for.sh fedora:8080
$script_root/wait-for.sh solr:8983

echo "migrating test database"
bundle exec rake db:migrate RAILS_ENV=test

echo "migrating + seeding dev databases"
bundle exec rake db:migrate
bundle exec rake db:seed
