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
export JAVA_OPTIONS="${JAVA_OPTIONS} \
  -Dfcrepo.modeshape.configuration=classpath:/config/jdbc-postgresql/repository.json \
  -Dfcrepo.postgresql.username=${FCREPO_POSTGRES_USER} \
  -Dfcrepo.postgresql.password=${FCREPO_POSTGRES_PASSWORD} \
  -Dfcrepo.postgresql.host=${db_host} \
  -Dfcrepo.postgresql.port=${db_port}"

# This block + the next (jetty-overrides) are copied from the NULib source.
# see: https://github.com/nulib/docker-fcrepo/blob/master/assets/fedora-entrypoint.sh#L3-L4
echo "Changing ownership of /data as $(whoami)"
chown jetty:jetty /data

# see: https://github.com/nulib/docker-fcrepo/blob/master/assets/fedora-entrypoint.sh#L20-L24
if [[ -d /jetty-overrides ]]; then
  cd /jetty-overrides
  for file in $(find . -type f); do cp $file ${JETTY_BASE}/$file; done
  cd -
fi

# JAVA_OPTIONS from our on-campus deploy, as recommended by FCRepo wiki,
# with pathways in for changing the min/max memory allotted to fcrepo
export JAVA_OPTIONS="${JAVA_OPTIONS} \
  -server \
  -Dfile.encoding=UTF-8 \
  -Xms${FCREPO_MIN_MEMORY:-512m} \
  -Xmx${FCREPO_MAX_MEMORY:-1024m} \
  -XX:NewSize=256m \
  -XX:MaxNewSize=256m \
  -XX:MetaspaceSize=64m \
  -XX:MaxMetaspaceSize=256m \
  -XX:+UseG1GC \
  -XX:+DisableExplicitGC"

# see: https://github.com/nulib/docker-fcrepo/blob/master/assets/fedora-entrypoint.sh#L40
su -s /bin/bash -c "exec /docker-entrypoint.sh $@" jetty
