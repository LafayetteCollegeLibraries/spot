#!/bin/bash

set -e

OLD_IFS=$IFS
IFS=','

for core in $SOLR_CORES
do
  precreate-core $core $SOLR_CORE_CONF_DIR
done

IFS=$OLD_IFS
