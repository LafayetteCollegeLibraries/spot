#!/bin/bash
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

# Generate a local SSL certificate so that we can run Rails on 443,
# but only if does not exist (prevents constantly creating a new cert)
ssl_key="$app_root/tmp/ssl/application.key"
ssl_cert="$app_root/tmp/ssl/application.crt"

if [[ ! -f "$ssl_key" && ! -f "$ssl_cert" ]]; then
  echo "generating ssl certificate"

  # @todo should these be ENV variables so we can reference them in the CMD?
  openssl req -x509 -nodes -newkey rsa:4096 \
    -keyout "$ssl_key" \
    -out "$ssl_cert" \
    -subj "/C=US/ST=Pennsylvania/L=Easton/O=Lafayette College/OU=ITS/CN=${APPLICATION_FQDN}"
fi

# The Google OAuth client used in Hyrax (for Analytics viewing) requires the private key
# to be in an actual file, so we'll decode the value from ENV and create the file.
if [[ ! -z "$HYRAX_ANALYTICS" && ! -z "$GOOGLE_OAUTH_PRIVATE_KEY_BASE64" ]]; then
  credentials_dir="$app_root/config/credentials"
  mkdir -p "$credentials_dir"

  credentials_path="$credentials_dir/google_oauth_private.key"
  echo -e "$GOOGLE_OAUTH_PRIVATE_KEY_BASE64" | base64 -d > "$credentials_path"

  export GOOGLE_OAUTH_PRIVATE_KEY_PATH="$credentials_path"

  unset credentials_dir
  unset credentials_path
fi

unset ssl_key
unset ssl_cert
unset app_root

# Kick off the service by running the CMD passed
exec "$@"
