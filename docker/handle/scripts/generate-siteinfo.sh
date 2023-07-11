#!/bin/bash

cat <<-EOINFO > $HANDLE_SERVER_HOME/siteinfo.json
{
  "version": 1,
  "protocolVersion": "2.10",
  "serialNumber": 1,
  "primarySite": true,
  "multiPrimary": false,
  "attributes": [
    {
      "name": "desc",
      "value": "${HANDLE_SERVER_DESCRIPTION:-"A containerized Handle.net server"}"
    }
  ],
  "servers": [
    {
      "serverId": 1,
      "address": "${HANDLE_HOST_IP:-"0.0.0.0"}",
      "publicKey": {
        "format": "base64",
        "value": "$(base64 -w 0 $HANDLE_SERVER_HOME/pubkey.bin)"
      },
      "interfaces": [
        {
          "query": true,
          "admin": true,
          "protocol": "TCP",
          "port": 2641
        },
        {
          "query": true,
          "admin": true,
          "protocol": "HTTP",
          "port": 8000
        }
      ]
   }
  ]
}
EOINFO
