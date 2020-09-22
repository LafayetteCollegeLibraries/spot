#!/bin/sh
set -e

# copy the dev UV configuration _after_ running yarn install.
# previously, i was adding this file with a volume link in the
# docker-compose#app config, but it was causing the `yarn install`
# command to fail because the file was unable to be deleted.
cp config/uv/uv-config-development.json public/uv/uv-config.json

# we're not copying over tmp directories, so we need to ensure that
# they exist on the the docker side, otherwise derivatives etc.
# won't be generated.
mkdir -p tmp/{export,pids}

exec "$@"
