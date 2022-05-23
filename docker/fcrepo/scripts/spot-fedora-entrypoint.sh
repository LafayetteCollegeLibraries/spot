#!/bin/bash

db_host="${FCREPO_POSTGRES_HOST}"
db_port="${FCREPO_POSTGRES_PORT:-5432}"

# need to wait for the database to complete initialization
while ! nc -z $db_host $db_port
do
  echo "waiting for $db_host:$db_port"
  sleep 1
done

export MODESHAPE_CONFIG="classpath:/config/jdbc-postgresql/repository.json"
export JAVA_OPTIONS="${JAVA_OPTIONS} \
  -Dfcrepo.postgresql.username=${FCREPO_POSTGRES_USER} \
  -Dfcrepo.postgresql.password=${FCREPO_POSTGRES_PASSWORD} \
  -Dfcrepo.postgresql.host=${db_host} \
  -Dfcrepo.postgresql.port=${db_port}"

exec /fedora-entrypoint.sh "$@"
