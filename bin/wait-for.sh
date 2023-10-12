#!/bin/bash
#
# copied from hyrax core. waits for connection to be available
# before executing passed code.
#
# usage:
#   wait-for.sh localhost:5432 bundle exec rails db:migrate

host=$(printf "%s\n" "$1"| cut -d : -f 1)
port=$(printf "%s\n" "$1"| cut -d : -f 2)

shift 1

while ! nc -z "$host" "$port"
do
  echo "waiting for $host:$port"
  sleep 1
done

exec "$@"
