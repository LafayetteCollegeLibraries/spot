#!/bin/bash
set -e

# set environment variables via sourcing so that they hang around for templating
. /hdl-scripts/handle-env.sh

# fill out our templates and write them to the handle server root
cat /hdl-templates/config.dct.template | envsubst > $HANDLE_SERVER_HOME/config.dct
cat /hdl-templates/siteinfo.json.template | envsubst > $HANDLE_SERVER_HOME/siteinfo.json

# create our certs from ENV PEM values
echo $SERVER_PUBLIC_KEY_PEM  | $HANDLE_SERVER_HOME/bin/hdl-convert-key -o $HANDLE_SERVER_HOME/pubkey.bin
echo $SERVER_PRIVATE_KEY_PEM | $HANDLE_SERVER_HOME/bin/hdl-convert-key -o $HANDLE_SERVER_HOME/privkey.bin

exec "$@"
