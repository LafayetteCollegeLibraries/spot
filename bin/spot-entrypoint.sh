#!/bin/sh
set -e

app_root="/spot"

# we're not copying over tmp directories, so we need to ensure that
# they exist on the the docker side, otherwise derivatives etc.
# won't be generated.
mkdir -p "$app_root/tmp/export"
mkdir -p "$app_root/tmp/pids"
mkdir -p "$app_root/tmp/ssl"
mkdir -p "${HYRAX_CACHE_PATH:-$app_root/tmp/cache}"
mkdir -p "${HYRAX_DERIVATIVES_PATH:-$app_root/tmp/derivatives}"
mkdir -p "${HYRAX_UPLOAD_PATH:-$app_root/tmp/uploads}"

# Generate a local SSL certificate so that we can run Rails on 443
echo "generating ssl certificate"
openssl req -x509 -nodes -newkey rsa:4096 \
    -keyout "$app_root/tmp/ssl/application.key" \
    -out "$app_root/tmp/ssl/application.crt" \
    -subj "/C=US/ST=Pennsylvania/L=Easton/O=Lafayette College/OU=ITS/CN=${APPLICATION_FQDN}"

rm -f tmp/pids/server.pid

exec "$@"
