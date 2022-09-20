#!/bin/bash
set -e

# create the certs using solr guide
# https://solr.apache.org/guide/8_11/enabling-ssl.html#generate-a-self-signed-certificate-and-a-key
keystore_folder="/var/ssl"
keystore_path="$keystore_folder/solr-ssl.keystore.p12"

mkdir -p "$keystore_folder"
keytool \
  -genkeypair \
  -alias solr-ssl \
  -keyalg RSA \
  -keysize 2048 \
  -keypass secret \
  -storepass secret \
  -validity 9999 \
  -keystore $keystore_path \
  -storetype PKCS12 \
  -ext SAN=DNS:localhost,DNS:${SOLR_HOST},IP:127.0.0.1 \
  -dname "CN=${SOLR_HOST}, OU=ITS, O=Lafayette College, L=Easton, ST=Pennsylvania,C=US"

# using configuration from https://solr.apache.org/guide/8_11/enabling-ssl.html#set-common-ssl-related-system-properties
export SOLR_SSL_ENABLED=true
export SOLR_SSL_KEY_STORE=$keystore_path
export SOLR_SSL_KEY_STORE_PASSWORD=secret
export SOLR_SSL_TRUST_STORE=$keystore_path
export SOLR_SSL_TRUST_STORE_PASSWORD=secret

# Require clients to authenticate
export SOLR_SSL_NEED_CLIENT_AUTH=false

# Enable clients to authenticate (but not require)
export SOLR_SSL_WANT_CLIENT_AUTH=false

# SSL Certificates contain host/ip "peer name" information that is validated by default. Setting
# this to false can be useful to disable these checks when re-using a certificate on many hosts
export SOLR_SSL_CHECK_PEER_NAME=false
