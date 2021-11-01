#!/bin/sh
set -e

# we're not copying over tmp directories, so we need to ensure that
# they exist on the the docker side, otherwise derivatives etc.
# won't be generated.
mkdir -p tmp/export
mkdir -p tmp/pids

exec "$@"
