#!/bin/bash
set -e

# create our certs from ENV PEM values
echo -e "$HANDLE_SERVER_PUBLIC_KEY"  | hdl-convert-key -o $HANDLE_SERVER_HOME/pubkey.bin
echo -e "$HANDLE_SERVER_PRIVATE_KEY" | hdl-convert-key -o $HANDLE_SERVER_HOME/privkey.bin

# add handle's scripts to the path
export PATH="$HANDLE_SERVER_HOME/bin:$PATH"

. /hdl-scripts/generate-config.sh
. /hdl-scripts/generate-siteinfo.sh

exec "$@"
