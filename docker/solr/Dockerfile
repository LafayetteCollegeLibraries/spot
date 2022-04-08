FROM solr:8
ARG CORE_NAME="spot"

COPY ../../solr/config /spot-config
RUN precreate-core $CORE_NAME /spot-config

# @todo run in cloud mode?
