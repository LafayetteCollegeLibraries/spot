#!/bin/bash
#
# we can't start fcrepo until the database has completed initialization,
# so we'll use netcat to scan the host + port and see if it's listening
db_host="${FCREPO_POSTGRES_HOST}"
db_port="${FCREPO_POSTGRES_PORT:-5432}"

while ! nc -z $db_host $db_port
do
  echo "waiting for $db_host:$db_port"
  sleep 1
done

# configure fcrepo to use postgres as the database for metadata
# NOTE: fcrepo uses the hard-coded "fcrepo" database, so you'll
#       need to ensure that the postgres service has one created.
export MODESHAPE_CONFIG="classpath:/config/jdbc-postgresql/repository.json"
export JAVA_OPTIONS="${JAVA_OPTIONS} \
  -Dfcrepo.postgresql.username=${FCREPO_POSTGRES_USER} \
  -Dfcrepo.postgresql.password=${FCREPO_POSTGRES_PASSWORD} \
  -Dfcrepo.postgresql.host=${db_host} \
  -Dfcrepo.postgresql.port=${db_port}"

exec /fedora-entrypoint.sh "$@"
