#!/bin/sh
set -e

app_root="/spot"

# we're not copying over tmp directories, so we need to ensure that
# they exist on the the docker side, otherwise derivatives etc.
# won't be generated.
mkdir -p "$app_root/tmp/export"
mkdir -p "$app_root/tmp/pids"
mkdir -p "$app_root/tmp/ssl"
mkdir -p "$HYRAX_CACHE_PATH"
mkdir -p "$HYRAX_DERIVATIVES_PATH"
mkdir -p "$HYRAX_UPLOAD_PATH"

# clear out any previous PIDs
rm -f "$app_root/tmp/pids/server.pid"

# Hyrax 3 uses the HYRAX_DERIVATIVES_PATH environment variable
# to establish where derivatives are stored, but Hyrax 2 uses
# the singular HYRAX_DERIVATIVE_PATH, so we'll need to set that
# for backwards compat.
#
# @todo remove after upgrading Hyrax
export HYRAX_DERIVATIVE_PATH=$HYRAX_DERIVATIVES_PATH

# Generate a local SSL certificate so that we can run Rails on 443,
# but only if does not exist (prevents constantly creating a new cert)
ssl_key="$app_root/tmp/ssl/application.key"
ssl_cert="$app_root/tmp/ssl/application.crt"

if [[ ! -f "$ssl_key" && ! -f "$ssl_cert" && -z "$SKIP_SSL_CERT" ]]; then
    echo "generating ssl certificate"

    # @todo should these be ENV variables so we can reference them in the CMD?
    openssl req -x509 -nodes -newkey rsa:4096 \
        -keyout "$ssl_key" \
        -out "$ssl_cert" \
        -subj "/C=US/ST=Pennsylvania/L=Easton/O=Lafayette College/OU=ITS/CN=${APPLICATION_FQDN}"

fi

unset ssl_key
unset ssl_cert
unset app_root

# Kick off the service by running the CMD passed
exec "$@"
