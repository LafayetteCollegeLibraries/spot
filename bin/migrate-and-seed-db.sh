#!/bin/sh

wait-for.sh db:5432
wait-for.sh fedora:8080
wait-for.sh solr:8983

bundle exec rails db:migrate
bundle exec rails db:seed
