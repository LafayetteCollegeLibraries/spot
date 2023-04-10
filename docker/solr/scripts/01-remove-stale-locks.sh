#!/bin/bash
#
# Clear out stale lockfiles that might hang around an EFS share when the container is booted.
# (We only intend on using a single instance of Solr, so the presence of a lockfile is
# assumed to be left behind when the previous container was killed.)
set -e

OLD_IFS=$IFS
IFS=','

for core in $SOLR_CORES
do
  lockfile_path="${SOLR_HOME}/${core}/data/index/write.lock"
  if [ -f "${lockfile_path}" ]; then
    echo "Removing existing lockfile at ${lockfile_path}"
    rm -f "${lockfile_path}"
  fi
done

IFS=$OLD_IFS
