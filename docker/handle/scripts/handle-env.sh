#!/bin/bash
set -e

if [[ ! -z ${HANDLE_PREFIX+x} ]]; then
  export SERVER_ADMINS="300:0.NA/$HANDLE_PREFIX"
  export REPLICATION_ADMINS="300:0.NA/$HANDLE_PREFIX"
  export AUTO_HOMED_PREFIXES="0.NA/$HANDLE_PREFIX"
fi

# for config.dct
export SERVER_ADMIN_FULL_ACCESS=${SERVER_ADMIN_FULL_ACCESS:-"yes"}
export CASE_SENSITIVE=${CASE_SENSITIVE:-"no"}
export MAX_SESSION_TIME=${MAX_SESSION_TIME:-"86400000"}
export MAX_AUTH_TIME=${MAX_AUTH_TIME:-"60000"}
export THIS_SERVER_ID=${THIS_SERVER_ID:-"1"}
export TRACE_RESOLUTION=${TRACE_RESOLUTION:-"no"}
export ALLOW_LIST_HDLS=${ALLOW_LIST_HDLS:-"yes"}
export ALLOW_RECURSION=${ALLOW_RECURSION:-"no"}
export SERVER_ADMINS=${SERVER_ADMINS:-""}
export REPLICATION_ADMINS=${REPLICATION_ADMINS:-""}
export AUTO_HOMED_PREFIXES=${AUTO_HOMED_PREFIXES:-""}
export ALLOW_NA_ADMINS=${ALLOW_NA_ADMINS:-"yes"}
export TEMPLATE_NS_OVERRIDE=${TEMPLATE_NS_OVERRIDE:-"no"}

# config.dct postgresql storage config
export STORAGE_TYPE=${STORAGE_TYPE:-"sql"}
export SQL_DRIVER=${SQL_DRIVER:-"org.postgresql.Driver"}
export SQL_USER=${SQL_USER:-""}
export SQL_PASSWORD=${SQL_PASSWORD:-""}
export SQL_HOST=${SQL_HOST:-"localhost"}
export SQL_PORT=${SQL_PORT:-"5432"}
export SQL_DATABASE=${SQL_DATABASE:-"handle"}
export SQL_URL=${SQL_URL:-"jdbc:postgresql://${SQL_HOST}:${SQL_PORT}/${SQL_DATABASE}?user=${SQL_USER}&password=${SQL_PASSWORD}"}
export SQL_READ_ONLY=${SQL_READ_ONLY:-"no"}

# for siteinfo.json
export HANDLE_HOST_IP=${HANDLE_HOST_IP:-"0.0.0.0"}

# base64 encoded string of the server's PUBLIC_KEY
export SERVER_PUBLIC_KEY_DSA_BASE64=$(echo $SERVER_PUBLIC_KEY_PEM | base64)
