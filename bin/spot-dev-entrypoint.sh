#!/bin/sh
set -e

app_root="/spot"

# copy the dev UV configuration _after_ running yarn install.
# previously, i was adding this file with a volume link in the
# docker-compose#app config, but it was causing the `yarn install`
# command to fail because the file was unable to be deleted.
mkdir -p "$app_root/public/uv"
cp "$app_root/config/uv/uv-config-development.json" "$app_root/public/uv/uv-config.json"

# we're not copying over tmp directories, so we need to ensure that
# they exist on the the docker side, otherwise derivatives etc.
# won't be generated.
mkdir -p "$app_root/tmp/export"
mkdir -p "$app_root/tmp/pids"
mkdir -p "$HYRAX_DERIVATIVES_PATH"

exec "$@"
