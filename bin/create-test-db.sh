#!/bin/bash
set -e

POSTGRES="psql"
DB_NAME=spot_test

echo "Creating test database: ${DB_NAME}"

psql -u "$POSTGRES_USER" <<EOSQL
CREATE DATABASE ${DB_NAME} OWNER ${POSTGRES_USER};
EOSQL
