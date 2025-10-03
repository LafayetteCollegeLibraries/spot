#! /bin/bash

# create the test core
precreate-core spot-test /solr-test-config

# carry on as usual
docker-entrypoint.sh "$@"