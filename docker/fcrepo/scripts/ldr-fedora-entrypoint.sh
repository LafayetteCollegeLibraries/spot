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

# JAVA_OPTIONS from our on-campus deploy, as recommended by FCRepo wiki,
# with pathways in for changing the min/max memory allotted to fcrepo.
# Metadata is stored in a PostgreSQL database named "fcrepo" (not configurable)
# and binary assets stored in a /data directory.
export JAVA_OPTIONS="${JAVA_OPTIONS} \
  -server \
  -Dfcrepo.home=/data \
  -Dfile.encoding=UTF-8 \
  -Xms${FCREPO_MIN_MEMORY:-512m} \
  -Xmx${FCREPO_MAX_MEMORY:-1024m} \
  -XX:NewSize=256m \
  -XX:MaxNewSize=256m \
  -XX:MetaspaceSize=64m \
  -XX:MaxMetaspaceSize=256m \
  -XX:+UseG1GC \
  -XX:+DisableExplicitGC \
  -Dfcrepo.modeshape.configuration=classpath:/config/jdbc-postgresql/repository.json \
  -Dfcrepo.postgresql.username=${FCREPO_POSTGRES_USER} \
  -Dfcrepo.postgresql.password=${FCREPO_POSTGRES_PASSWORD} \
  -Dfcrepo.postgresql.host=${db_host} \
  -Dfcrepo.postgresql.port=${db_port}"

echo "Changing ownership of /data as $(whoami)"
chown jetty:jetty /data

if [[ -d /jetty-overrides ]]; then
  cd /jetty-overrides
  for file in $(find . -type f); do cp $file ${JETTY_BASE}/$file; done
  cd -
fi

# see: https://github.com/scientist-softserv/docker-fcrepo/blob/c8b4774da76a6f74fd3df965f1a006ab031ad4c8/assets/fedora-entrypoint.sh#L39
su -s /bin/bash -c "JAVA_HOME=/opt/java/openjdk; PATH=$PATH:/usr/local/jetty/bin:/opt/java/openjdk/bin; exec /docker-entrypoint.sh $@" jetty
