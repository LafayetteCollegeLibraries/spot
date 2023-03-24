#!/bin/bash

if [[ ! -z "$AWS_IIIF_ASSET_BUCKET" ]]; then
  echo "creating s3 buckets"
  aws --endpoint-url="${AWS_ENDPOINT_URL:-"http://localhost:9000"}" s3 mb "s3://${AWS_IIIF_ASSET_BUCKET}"
  aws --endpoint-url="${AWS_ENDPOINT_URL:-"http://localhost:9000"}" s3 mb "s3://${AWS_BULKRAX_IMPORT_BUCKET}"
fi

if [[ ! -z "$AWS_BULKRAX_IMPORTS_BUCKET" ]]; then
  echo "creating s3 buckets"
  aws --endpoint-url="${AWS_ENDPOINT_URL:-"http://localhost:9000"}" s3 mb "s3://${AWS_BULKRAX_IMPORTS_BUCKET}"
fi

if [[ ! -z "$AWS_BULKRAX_IMPORTS_BUCKET" ]]; then
  echo "creating s3 buckets"
  aws --endpoint-url="${AWS_ENDPOINT_URL:-"http://localhost:9000"}" s3 mb "s3://${AWS_BULKRAX_IMPORTS_BUCKET}"
fi

if [[ ! -z "$AWS_BULKRAX_IMPORTS_BUCKET" ]]; then
  echo "creating s3 buckets"
  aws --endpoint-url="${AWS_ENDPOINT_URL:-"http://localhost:9000"}" s3 mb "s3://${AWS_BULKRAX_IMPORTS_BUCKET}"
fi

script_root="$(dirname $0)"
$script_root/wait-for.sh db:5432

echo "migrating test database"
bundle exec rails db:migrate RAILS_ENV=test

echo "migrating dev databases"
bundle exec rails db:migrate

$script_root/wait-for.sh solr:8983
$script_root/wait-for.sh fedora:8080

echo "seeding dev databases"
bundle exec rails db:seed

